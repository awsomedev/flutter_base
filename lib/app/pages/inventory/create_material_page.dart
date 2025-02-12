import 'dart:io';

import 'package:flutter/material.dart';
import 'package:madeira/app/widgets/image_list_picker.dart';
import '../../models/material_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';

class CreateMaterialPage extends StatefulWidget {
  final MaterialModel? material;
  final int? categoryId;

  const CreateMaterialPage({
    Key? key,
    this.material,
    this.categoryId,
  }) : super(key: key);

  @override
  State<CreateMaterialPage> createState() => _CreateMaterialPageState();
}

class _CreateMaterialPageState extends State<CreateMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameMalayalamController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colourController = TextEditingController();
  final _qualityController = TextEditingController();
  final _durabilityController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  List<File> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _nameController.text = widget.material!.name;
      _descriptionController.text = widget.material!.description;
      _colourController.text = widget.material!.colour;
      _qualityController.text = widget.material!.quality;
      _durabilityController.text = widget.material!.durability;
      _priceController.text = widget.material!.price.toString();
      _quantityController.text = widget.material!.quantity?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colourController.dispose();
    _qualityController.dispose();
    _durabilityController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
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

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final materialData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'colour': _colourController.text,
        'quality': _qualityController.text,
        'durability': _durabilityController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.tryParse(_quantityController.text),
        'category': widget.categoryId,
        'name_mal': _nameMalayalamController.text,
      };

      if (widget.material != null) {
        await Services()
            .updateMaterial(widget.material!.id, materialData, _images);
        if (mounted) {
          _showSnackBar('Material updated successfully', false);
          Navigator.pop(context, true);
        }
      } else {
        await Services().createMaterial(materialData, _images);
        if (mounted) {
          _showSnackBar('Material created successfully', false);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save material: $e', true);
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
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.material != null ? 'Edit Material' : 'Create Material',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
              ),
              _buildTextField(
                controller: _nameMalayalamController,
                label: 'Name(Mal)',
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
              ),
              _buildTextField(
                controller: _colourController,
                label: 'Color',
              ),
              _buildTextField(
                controller: _qualityController,
                label: 'Quality',
              ),
              _buildTextField(
                controller: _durabilityController,
                label: 'Durability',
              ),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _quantityController,
                label: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ImageListPicker(
                onAdd: (images, _) {
                  setState(() {
                    _images = images.map((e) => e.file!).toList();
                  });
                },
                onRemove: (images, _) {
                  setState(() {
                    _images = images.map((e) => e.file!).toList();
                  });
                },
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
                  onPressed: _isLoading ? null : _saveMaterial,
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
                      : Text(widget.material != null
                          ? 'Update Material'
                          : 'Create Material'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
