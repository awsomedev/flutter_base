import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:madeira/app/models/decorations_response_model.dart';
import '../../models/category_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';

class CreateDecorationEnquiryPage extends StatefulWidget {
  final DecorationResponse? decoration;

  const CreateDecorationEnquiryPage({Key? key, this.decoration})
      : super(key: key);

  @override
  State<CreateDecorationEnquiryPage> createState() =>
      _CreateDecorationEnquiryPageState();
}

class _CreateDecorationEnquiryPageState
    extends State<CreateDecorationEnquiryPage> {
  final _formKey = GlobalKey<FormState>();
  final _enquiryNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.decoration != null) {
      _enquiryNameController.text = widget.decoration!.enquiryName;
    }
  }

  @override
  void dispose() {
    _enquiryNameController.dispose();
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

  Future<void> _saveDecoration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final decorationData = _enquiryNameController.text;

      if (widget.decoration != null) {
        await Services().updateDecoration(
          widget.decoration!.id,
          decorationData,
        );
        _showSnackBar('Decoration enquiry updated successfully', false);
      } else {
        await Services().createDecoration(decorationData);
        _showSnackBar('Decoration enquiry created successfully', false);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Failed to save decoration enquiry: $e', true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.decoration != null ? 'Edit Decoration' : 'Create Decoration',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _enquiryNameController,
                decoration: const InputDecoration(
                  labelText: 'Enquiry Name',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: AppColors.textPrimary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a decoration name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                  ),
                  onPressed: _isLoading ? null : _saveDecoration,
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
                      : Text(widget.decoration != null ? 'Update' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
