import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class WorkerFormScreen extends StatefulWidget {
  final Worker? worker;

  const WorkerFormScreen({super.key, this.worker});

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nationalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  WorkerRole _selectedRole = WorkerRole.technician;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.worker != null) {
      _nameController.text = widget.worker!.name;
      _nationalCodeController.text = widget.worker!.nationalCode;
      _phoneController.text = widget.worker!.phone;
      _selectedRole = widget.worker!.role;
      _addressController.text = widget.worker!.address ?? '';
      _emergencyContactController.text = widget.worker!.emergencyContact ?? '';
      _emergencyPhoneController.text = widget.worker!.emergencyPhone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalCodeController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final worker = Worker(
      id: widget.worker?.id,
      name: _nameController.text.trim(),
      nationalCode: _nationalCodeController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim().isEmpty
          ? null
          : _emergencyContactController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
          ? null
          : _emergencyPhoneController.text.trim(),
      createdAt: widget.worker?.createdAt ?? DateTime.now(),
      isActive: widget.worker?.isActive ?? true,
    );

    try {
      if (widget.worker == null) {
        await DatabaseService.instance.insertWorker(worker);
      } else {
        await DatabaseService.instance.updateWorker(worker);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.worker != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        isEdit ? 'ویرایش نیرو' : 'افزودن نیرو جدید',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'نام و نام خانوادگی *',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => v?.trim().isEmpty == true ? 'نام الزامی است' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nationalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'کد ملی *',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v?.trim().isEmpty == true) return 'کد ملی الزامی است';
                            if (v!.length != 10) return 'کد ملی باید ۱۰ رقم باشد';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'شماره تماس *',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v?.trim().isEmpty == true ? 'تلفن الزامی است' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<WorkerRole>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'سمت *',
                            prefixIcon: Icon(Icons.work),
                          ),
                          items: WorkerRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.label),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'اطلاعات تکمیلی',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'آدرس',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emergencyContactController,
                          decoration: const InputDecoration(
                            labelText: 'نام شخص مراجعه در مواقع اضطراری',
                            prefixIcon: Icon(Icons.contact_emergency),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emergencyPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'تلفن اضطراری',
                            prefixIcon: Icon(Icons.phone_in_talk),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: _isLoading ? null : _save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(isEdit ? 'بروزرسانی' : 'ذخیره'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}