import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/jalali_utils.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Worker> _workers = [];
  Map<int, AttendanceRecord> _attendanceMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final workers = await DatabaseService.instance.getAllWorkers();
      final records = await DatabaseService.instance.getAttendanceByDate(_selectedDate);
      final map = <int, AttendanceRecord>{};
      for (final record in records) {
        map[record.workerId] = record;
      }

      if (!mounted) return;
      setState(() {
        _workers = workers;
        _attendanceMap = map;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در بارگذاری حضور و غیاب: $error')),
      );
    }
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
    if (!mounted || picked == null) return;
    setState(() => _selectedDate = picked);
    await _loadData();
  }

  Future<void> _saveAttendance(Worker worker, AttendanceStatus status,
      {String? note, DateTime? checkIn, DateTime? checkOut, String? location}) async {
    final existing = _attendanceMap[worker.id!];
    final record = AttendanceRecord(
      id: existing?.id,
      workerId: worker.id!,
      date: existing?.date ?? JalaliUtils.startOfDay(_selectedDate),
      status: status,
      note: note,
      checkInTime: checkIn,
      checkOutTime: checkOut,
      location: location,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    try {
      if (existing != null) {
        await DatabaseService.instance.updateAttendance(record);
      } else {
        await DatabaseService.instance.insertAttendance(record);
      }
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ذخیره حضور و غیاب: $error')),
      );
    }
  }

  Future<void> _showAttendanceDialog(Worker worker) async {
    final existing = _attendanceMap[worker.id!];
    AttendanceStatus selectedStatus = existing?.status ?? AttendanceStatus.present;
    final noteController = TextEditingController(text: existing?.note);
    TimeOfDay? checkInTime = existing?.checkInTime != null
        ? TimeOfDay.fromDateTime(existing!.checkInTime!)
        : null;
    TimeOfDay? checkOutTime = existing?.checkOutTime != null
        ? TimeOfDay.fromDateTime(existing!.checkOutTime!)
        : null;
    final locationController = TextEditingController(text: existing?.location);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('ثبت حضور - ${worker.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  JalaliUtils.formatDate(_selectedDate, withWeekDay: true),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AttendanceStatus.values.map((status) {
                    final isSelected = selectedStatus == status;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(status.icon, size: 16, color: isSelected ? Colors.white : status.color),
                          const SizedBox(width: 4),
                          Text(status.label),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: status.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : status.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => selectedStatus = status),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.login),
                        label: Text(checkInTime != null
                            ? JalaliUtils.toPersianDigitsInt(checkInTime!.hour).padLeft(2, '۰') +
                                ':' +
                                JalaliUtils.toPersianDigitsInt(checkInTime!.minute).padLeft(2, '۰')
                            : 'ساعت ورود'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: checkInTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) setState(() => checkInTime = picked);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: Text(checkOutTime != null
                            ? JalaliUtils.toPersianDigitsInt(checkOutTime!.hour).padLeft(2, '۰') +
                                ':' +
                                JalaliUtils.toPersianDigitsInt(checkOutTime!.minute).padLeft(2, '۰')
                            : 'ساعت خروج'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: checkOutTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) setState(() => checkOutTime = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'موقعیت مکانی',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _saveAttendance(
                  worker,
                  selectedStatus,
                  note: noteController.text.isEmpty ? null : noteController.text,
                  checkIn: checkInTime != null
                      ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
                          checkInTime!.hour, checkInTime!.minute)
                      : null,
                  checkOut: checkOutTime != null
                      ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
                          checkOutTime!.hour, checkOutTime!.minute)
                      : null,
                  location: locationController.text.isEmpty ? null : locationController.text,
                );
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
    noteController.dispose();
    locationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت حضور و غیاب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
            tooltip: 'تغییر تاریخ',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _workers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            const Text('هیچ نیرویی ثبت نشده است'),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _workers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final worker = _workers[index];
                          final record = _attendanceMap[worker.id!];
                          return _buildWorkerAttendanceTile(worker, record);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                JalaliUtils.formatDate(_selectedDate, withWeekDay: true),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickStat('حاضر', _countStatus(AttendanceStatus.present), Colors.green),
              const SizedBox(width: 24),
              _buildQuickStat('غایب', _countStatus(AttendanceStatus.absent), Colors.red),
              const SizedBox(width: 24),
              _buildQuickStat('دیر', _countStatus(AttendanceStatus.late), Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  int _countStatus(AttendanceStatus status) {
    return _attendanceMap.values.where((r) => r.status == status).length;
  }

  Widget _buildQuickStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Widget _buildWorkerAttendanceTile(Worker worker, AttendanceRecord? record) {
    return Card(
      child: InkWell(
        onTap: () => _showAttendanceDialog(worker),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: record?.status.color.withOpacity(0.1) ??
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  record?.status.icon ?? Icons.help_outline,
                  color: record?.status.color ?? Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      worker.role.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (record != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: record.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.status.label,
                    style: TextStyle(
                      color: record.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
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
                '${JalaliUtils.monthName(_month)} ${JalaliUtils.toPersianDigitsInt(_year)}',
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