import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/jalali_utils.dart';
import 'worker_form_screen.dart';

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  List<AttendanceRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseService.instance.getAttendanceByWorker(widget.worker.id!);
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;

    return Scaffold(
      appBar: AppBar(
        title: Text(worker.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildProfileCard(worker),
                ),
                SliverToBoxAdapter(
                  child: _buildStatsCards(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'تاریخچه حضور و غیاب',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildRecordsList(),
              ],
            ),
    );
  }

  Widget _buildProfileCard(Worker worker) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getRoleIcon(worker.role),
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              worker.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                worker.role.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.badge, 'کد ملی', worker.nationalCode),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'تلفن', worker.phone),
            if (worker.address != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, 'آدرس', worker.address!),
            ],
            if (worker.emergencyContact != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.contact_emergency, 'تماس اضطراری', worker.emergencyContact!),
            ],
            if (worker.emergencyPhone != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone_in_talk, 'تلفن اضطراری', worker.emergencyPhone!),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'تاریخ ثبت',
              JalaliUtils.formatDate(worker.createdAt, withWeekDay: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final stats = _calculateStats();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _StatCard('حاضر', stats[AttendanceStatus.present]!, Colors.green, Icons.check_circle)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard('غایب', stats[AttendanceStatus.absent]!, Colors.red, Icons.cancel)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard('دیر', stats[AttendanceStatus.late]!, Colors.orange, Icons.access_time)),
        ],
      ),
    );
  }

  Map<AttendanceStatus, int> _calculateStats() {
    final map = <AttendanceStatus, int>{};
    for (final r in _records) {
      map[r.status] = (map[r.status] ?? 0) + 1;
    }
    return map;
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'هیچ سابقه الحضوری وجود ندارد',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = _records[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: record.status.color.withValues(alpha: 0.1),
              child: Icon(record.status.icon, color: record.status.color),
            ),
            title: Text(
              JalaliUtils.formatDate(record.date, withWeekDay: true),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (record.checkInTime != null) ...[
                      Icon(Icons.login, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        JalaliUtils.formatTime(record.checkInTime!),
                        style: TextStyle(fontSize: 12, color: Colors.green[700]),
                      ),
                    ],
                    const SizedBox(width: 12),
                    if (record.checkOutTime != null) ...[
                      Icon(Icons.logout, size: 14, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        JalaliUtils.formatTime(record.checkOutTime!),
                        style: TextStyle(fontSize: 12, color: Colors.red[700]),
                      ),
                    ],
                  ],
                ),
                if (record.note != null) ...[
                  const SizedBox(height: 4),
                  Text(record.note!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
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

  void _showEditForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WorkerFormScreen(worker: widget.worker),
    ).then((_) => _loadRecords());
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard(this.label, this.count, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}