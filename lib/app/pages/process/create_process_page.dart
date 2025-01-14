import 'package:flutter/material.dart';
import '../../models/process_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';

class CreateProcessPage extends StatefulWidget {
  final Process? process;

  const CreateProcessPage({
    Key? key,
    this.process,
  }) : super(key: key);

  @override
  State<CreateProcessPage> createState() => _CreateProcessPageState();
}

class _CreateProcessPageState extends State<CreateProcessPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameMalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionMalController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.process != null) {
      _nameController.text = widget.process!.name ?? '';
      _nameMalController.text = widget.process!.nameMal ?? '';
      _descriptionController.text = widget.process!.description ?? '';
      _descriptionMalController.text = widget.process!.descriptionMal ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameMalController.dispose();
    _descriptionController.dispose();
    _descriptionMalController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _saveProcess() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final processData = {
        'name': _nameController.text,
        'name_mal': _nameMalController.text,
        'description': _descriptionController.text,
        'description_mal': _descriptionMalController.text,
      };

      if (widget.process != null && widget.process!.id != null) {
        await Services().updateProcess(widget.process!.id!, processData);
        if (mounted) {
          _showSnackBar('Process updated successfully', false);
          Navigator.pop(context, true);
        }
      } else {
        await Services().createProcess(processData);
        if (mounted) {
          _showSnackBar('Process created successfully', false);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save process: $e', true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(color: AppColors.textPrimary),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.process != null ? 'Edit Process' : 'Create Process',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'English',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Malayalam',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameMalController,
                label: 'Name in Malayalam',
              ),
              _buildTextField(
                controller: _descriptionMalController,
                label: 'Description in Malayalam',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _saveProcess,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.background,
                            ),
                          ),
                        )
                      : Text(
                          widget.process != null
                              ? 'Update Process'
                              : 'Create Process',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
