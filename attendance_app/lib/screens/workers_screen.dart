import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../utils/jalali_utils.dart';
import 'worker_form_screen.dart';
import 'worker_detail_screen.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkers();
    _searchController.addListener(_filterWorkers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    final workers = await DatabaseService.instance.getAllWorkers(activeOnly: false);
    setState(() {
      _workers = workers;
      _filteredWorkers = workers;
      _isLoading = false;
    });
  }

  void _filterWorkers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWorkers = _workers.where((w) {
        return w.name.toLowerCase().contains(query) ||
            w.nationalCode.contains(query) ||
            w.phone.contains(query);
      }).toList();
    });
  }

  Future<void> _toggleActive(Worker worker) async {
    final updated = worker.copyWith(isActive: !worker.isActive);
    await DatabaseService.instance.updateWorker(updated);
    _loadWorkers();
  }

  Future<void> _deleteWorker(Worker worker) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف نیرو'),
        content: Text('آیا از حذف ${worker.name} مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteWorker(worker.id!);
      _loadWorkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت نیروها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showWorkerForm(),
            tooltip: 'افزودن نیرو',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجو بر اساس نام، کد ملی، تلفن...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWorkers.isEmpty
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
                            Text(
                              _searchController.text.isEmpty
                                  ? 'هیچ نیرویی ثبت نشده است'
                                  : 'نیرویی یافت نشد',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            if (_searchController.text.isEmpty)
                              FilledButton.icon(
                                onPressed: _showWorkerForm,
                                icon: const Icon(Icons.add),
                                label: const Text('افزودن نیرو اول'),
                              ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredWorkers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final worker = _filteredWorkers[index];
                          return _buildWorkerCard(worker);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(Worker worker) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerDetailScreen(worker: worker),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: worker.isActive
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.grey[300],
                child: Icon(
                  _getRoleIcon(worker.role),
                  color: worker.isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            worker.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: worker.isActive ? null : Colors.grey,
                            ),
                          ),
                        ),
                        if (!worker.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'غیرفعال',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'کد ملی: ${worker.nationalCode}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      worker.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showWorkerForm(worker: worker);
                      break;
                    case 'toggle':
                      _toggleActive(worker);
                      break;
                    case 'delete':
                      _deleteWorker(worker);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('ویرایش'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(worker.isActive ? Icons.block : Icons.check_circle, size: 18),
                        const SizedBox(width: 8),
                        Text(worker.isActive ? 'غیرفعال کردن' : 'فعال کردن'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  void _showWorkerForm({Worker? worker}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WorkerFormScreen(worker: worker),
    ).then((_) => _loadWorkers());
  }
}