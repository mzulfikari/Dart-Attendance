import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/report_service.dart';
import '../utils/jalali_utils.dart';
import 'workers_screen.dart';
import 'attendance_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  List<AttendanceRecord> _todayRecords = [];
  Map<String, int> _todayStats = {};
  int _totalWorkers = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const WorkersScreen(),
    const AttendanceScreen(),
    const ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final workers = await DatabaseService.instance.getAllWorkers();
    final records = await DatabaseService.instance.getAttendanceByDate(_selectedDate);
    final stats = await DatabaseService.instance.getAttendanceStats(
      JalaliUtils.startOfDay(_selectedDate),
      JalaliUtils.endOfDay(_selectedDate),
    );

    setState(() {
      _totalWorkers = workers.length;
      _todayRecords = records;
      _todayStats = stats;
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTabChanged,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'داشبورد',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'نیروها',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'حضور و غیاب',
            ),
            NavigationDestination(
              icon: Icon(Icons.assessment_outlined),
              selectedIcon: Icon(Icons.assessment),
              label: 'گزارشات',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  DateTime _selectedDate = DateTime.now();
  List<AttendanceRecord> _todayRecords = [];
  Map<String, int> _todayStats = {};
  int _totalWorkers = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final workers = await DatabaseService.instance.getAllWorkers();
    final records = await DatabaseService.instance.getAttendanceByDate(_selectedDate);
    final stats = await DatabaseService.instance.getAttendanceStats(
      JalaliUtils.startOfDay(_selectedDate),
      JalaliUtils.endOfDay(_selectedDate),
    );

    setState(() {
      _totalWorkers = workers.length;
      _todayRecords = records;
      _todayStats = stats;
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final jalali = JalaliUtils.toJalali(_selectedDate);
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _JalaliDatePicker(
        initialYear: jalali.year,
        initialMonth: jalali.month,
        initialDay: jalali.day,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('داشبورد مدیریت حضور و غیاب'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: _pickDate,
              tooltip: 'تغییر تاریخ',
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateCard(),
                const SizedBox(height: 16),
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildRecentRecords(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard() {
    return Card(
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      JalaliUtils.formatDate(_selectedDate, withWeekDay: true),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      JalaliUtils.getRelativeDateString(_selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = [
      ('کل نیروها', _totalWorkers.toString(), Icons.people, Colors.blue),
      ('حاضر', (_todayStats['حاضر'] ?? 0).toString(), Icons.check_circle, Colors.green),
      ('غایب', (_todayStats['غایب'] ?? 0).toString(), Icons.cancel, Colors.red),
      ('دیر آمدن', (_todayStats['دیر آمدن'] ?? 0).toString(), Icons.access_time, Colors.orange),
      ('مرخصی', (_todayStats['مرخصی'] ?? 0).toString(), Icons.beach_access, Colors.blue),
      ('ماموریت', (_todayStats['ماموریت'] ?? 0).toString(), Icons.directions_car, Colors.purple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final (label, value, icon, color) = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentRecords() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'حضور و غیاب امروز',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to attendance screen
              },
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('مشاهده همه'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_todayRecords.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'هیچ ثبت حضوری برای امروز وجود ندارد',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayRecords.length > 5 ? 5 : _todayRecords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = _todayRecords[index];
              return _buildRecordTile(record);
            },
          ),
      ],
    );
  }

  Widget _buildRecordTile(AttendanceRecord record) {
    return FutureBuilder<Worker?>(
      future: DatabaseService.instance.getWorkerById(record.workerId),
      builder: (context, snapshot) {
        final worker = snapshot.data;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: record.status.color.withValues(alpha: 0.1),
              child: Icon(record.status.icon, color: record.status.color),
            ),
            title: Text(worker?.name ?? 'نیرو ناشناس'),
            subtitle: Text(worker?.nationalCode ?? ''),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: record.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                record.status.label,
                style: TextStyle(
                  color: record.status.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
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
                onPressed: () => setState(() {
                  _month = _month > 1 ? _month - 1 : 12;
                  if (_month == 12) _year--;
                }),
              ),
              Text(
                '${JalaliUtils._persianMonths[_month - 1]} ${JalaliUtils.toPersianDigitsInt(_year)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _month = _month < 12 ? _month + 1 : 1;
                  if (_month == 1) _year++;
                }),
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
                    final gregorian = JalaliUtils.toGregorian(
                      JalaliDateTime(_year, _month, _day),
                    );
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