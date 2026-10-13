import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/report_service.dart';
import '../utils/jalali_utils.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0;
  DateTime _startDate = JalaliUtils.startOfMonth(DateTime.now());
  DateTime _endDate = JalaliUtils.endOfMonth(DateTime.now());
  List<Worker> _workers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      final workers = await DatabaseService.instance.getAllWorkers();
      if (mounted) setState(() => _workers = workers);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در بارگذاری فهرست نیروها: $error')),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await _showJalaliPicker(_startDate);
    if (!mounted || picked == null) return;
    setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await _showJalaliPicker(_endDate);
    if (!mounted || picked == null) return;
    setState(() => _endDate = picked);
  }

  Future<DateTime?> _showJalaliPicker(DateTime initial) async {
    final jalali = JalaliUtils.toJalali(initial);
    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _JalaliDatePicker(
        initialYear: jalali.year,
        initialMonth: jalali.month,
        initialDay: jalali.day,
      ),
    );
  }

  Future<void> _generateDailyReport() async {
    setState(() => _isLoading = true);
    try {
      final records = await DatabaseService.instance.getAttendanceByDate(_startDate);
      await ReportService.generateDailyReportPdf(
        date: _startDate,
        records: records,
        workers: _workers,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateDateRange() {
    if (!_startDate.isAfter(_endDate)) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تاریخ شروع نباید بعد از تاریخ پایان باشد')),
    );
    return false;
  }

  Future<void> _generateMonthlyReport() async {
    if (!_validateDateRange()) return;
    setState(() => _isLoading = true);
    try {
      final records = await DatabaseService.instance.getAttendanceRange(_startDate, _endDate);
      await ReportService.generateMonthlyReportPdf(
        startDate: _startDate,
        endDate: _endDate,
        workers: _workers,
        records: records,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateExcelReport() async {
    if (!_validateDateRange()) return;
    setState(() => _isLoading = true);
    try {
      final records = await DatabaseService.instance.getAttendanceRange(_startDate, _endDate);
      await ReportService.generateExcelReport(
        startDate: _startDate,
        endDate: _endDate,
        workers: _workers,
        records: records,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateWorkerReport(Worker worker) async {
    if (!_validateDateRange()) return;
    setState(() => _isLoading = true);
    try {
      final records = await DatabaseService.instance.getAttendanceByWorker(worker.id!);
      final filtered = records.where((r) {
        final d = JalaliUtils.startOfDay(r.date);
        return !d.isBefore(_startDate) && !d.isAfter(_endDate);
      }).toList();
      await ReportService.generateWorkerReportPdf(
        worker: worker,
        records: filtered,
        startDate: _startDate,
        endDate: _endDate,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گزارشات'),
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 8),
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildDailyReportTab(),
                _buildMonthlyReportTab(),
                _buildWorkerReportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بازه زمانی گزارش',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickStartDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'از تاریخ',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(JalaliUtils.formatDate(_startDate, withWeekDay: true)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickEndDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'تا تاریخ',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(JalaliUtils.formatDate(_endDate, withWeekDay: true)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'گزارش روزانه',
              icon: Icons.today,
              isSelected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: 'گزارش ماهانه',
              icon: Icons.calendar_view_month,
              isSelected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: 'گزارش کارمندی',
              icon: Icons.person,
              isSelected: _selectedTab == 2,
              onTap: () => setState(() => _selectedTab = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReportCard(
          title: 'گزارش PDF روزانه',
          subtitle: 'خلاصه حضور و غیاب تمام نیروها برای تاریخ انتخاب شده',
          icon: Icons.picture_as_pdf,
          color: Colors.red,
          isLoading: _isLoading,
          onTap: _generateDailyReport,
        ),
        const SizedBox(height: 12),
        _ReportCard(
          title: 'مشاهده حضور امروز',
          subtitle: 'نمایش لیست حضور و غیاب در صفحه حضور و غیاب',
          icon: Icons.visibility,
          color: Colors.blue,
          onTap: () {
            // Navigate to attendance screen
            // This would need a navigator key or callback
          },
        ),
      ],
    );
  }

  Widget _buildMonthlyReportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReportCard(
          title: 'گزارش PDF ماهانه',
          subtitle: 'جدول کامل حضور و غیاب همه نیروها در بازه زمانی',
          icon: Icons.picture_as_pdf,
          color: Colors.red,
          isLoading: _isLoading,
          onTap: _generateMonthlyReport,
        ),
        const SizedBox(height: 12),
        _ReportCard(
          title: 'گزارش اکسل (Excel)',
          subtitle: 'فایل اکسل قابل ویرایش برای آرشیو و تحلیل',
          icon: Icons.table_chart,
          color: Colors.green,
          isLoading: _isLoading,
          onTap: _generateExcelReport,
        ),
      ],
    );
  }

  Widget _buildWorkerReportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'انتخاب نیرو برای گزارش فردی',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_workers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('هیچ نیرویی ثبت نشده است'),
              ),
            ),
          )
        else
          ..._workers.map((w) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(_getRoleIcon(w.role)),
                  ),
                  title: Text(w.name),
                  subtitle: Text('${w.nationalCode} • ${w.role.label}'),
                  trailing: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton(
                          onPressed: () => _generateWorkerReport(w),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(80, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('گزارش'),
                        ),
                  onTap: () => _generateWorkerReport(w),
                ),
              )),
      ],
    );
  }

  IconData _getRoleIcon(WorkerRole role) {
    switch (role) {
      case WorkerRole.engineer:
        return Icons.engineering;
      case WorkerRole.technician:
        return Icons.build;
      case WorkerRole.supervisor:
        return Icons.supervisor_account;
      case WorkerRole.helper:
        return Icons.handyman;
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JalaliDatePicker extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int initialDay;

  const _JalaliDatePicker({
    required this.initialYear,
    required this.initialMonth,
    required this.initialDay,
  });

  @override
  State<_JalaliDatePicker> createState() => _JalaliDatePickerState();
}

class _JalaliDatePickerState extends State<_JalaliDatePicker> {
  late int _year;
  late int _month;
  late int _day;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
    _day = widget.initialDay;
  }

  void _changeMonth(int offset) {
    setState(() {
      if (offset < 0) {
        if (_month == 1) {
          _month = 12;
          _year--;
        } else {
          _month--;
        }
      } else {
        if (_month == 12) {
          _month = 1;
          _year++;
        } else {
          _month++;
        }
      }
      final lastDay = JalaliUtils.getDaysInJalaliMonth(_year, _month);
      if (_day > lastDay) _day = lastDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = JalaliUtils.getDaysInJalaliMonth(_year, _month);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                '${JalaliUtils.monthName(_month)} ${JalaliUtils.toPersianDigitsInt(_year)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isSelected = day == _day;
                return InkWell(
                  onTap: () => setState(() => _day = day),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        JalaliUtils.toPersianDigitsInt(day),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('انصراف'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final gregorian = JalaliUtils.fromJalaliParts(_year, _month, _day);
                    Navigator.pop(context, gregorian);
                  },
                  child: const Text('تأیید'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}