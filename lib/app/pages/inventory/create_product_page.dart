import 'dart:io';

import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/widgets/image_list_picker.dart';
import 'package:madeira/app/widgets/searchable_picker.dart';
import '../../models/product_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';

class CreateProductPage extends StatefulWidget {
  final ProductModel? product;
  final int? categoryId;

  const CreateProductPage({
    Key? key,
    this.product,
    this.categoryId,
  }) : super(key: key);

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameMalayalamController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colourController = TextEditingController();
  final _qualityController = TextEditingController();
  final _durabilityController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionMalayalamController = TextEditingController();
  final _mrpInGstController = TextEditingController();
  List<File> _images = [];
  List<String> _existingImages = [];
  bool _isLoading = false;
  StockAvailability _selectedStockAvailability = StockAvailability.inStock;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name ?? '';
      _nameMalayalamController.text = widget.product!.nameMal ?? '';
      _descriptionController.text = widget.product!.description ?? '';
      _colourController.text = widget.product!.colour ?? '';
      _qualityController.text = widget.product!.quality ?? '';
      _durabilityController.text = widget.product!.durability ?? '';
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity?.toString() ?? '';
      _codeController.text = widget.product!.code ?? '';
      _descriptionMalayalamController.text =
          widget.product!.descriptionMal ?? '';
      _mrpInGstController.text = widget.product!.mrpInGst.toString();
      _selectedStockAvailability = StockAvailability.fromValue(
          widget.product!.stockAvailability ?? 'in_stock');
      _existingImages =
          widget.product?.images.map((e) => e.image.toImageUrl).toList() ?? [];
    } else {
      _mrpInGstController.text = '0';
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
    _codeController.dispose();
    _nameMalayalamController.dispose();
    _descriptionMalayalamController.dispose();
    _mrpInGstController.dispose();
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

  Future<void> _selectStockAvailability() async {
    final result = await showModalBottomSheet<StockAvailability>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<StockAvailability>(
        title: 'Select Stock Availability',
        items: StockAvailability.values.toList(),
        getLabel: (availability) => availability.displayName,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedStockAvailability = result;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'colour': _colourController.text,
        'quality': _qualityController.text,
        'durability': _durabilityController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.tryParse(_quantityController.text),
        'category_id': widget.categoryId,
        'name_mal': _nameMalayalamController.text,
        'code': _codeController.text,
        'description_mal': _descriptionMalayalamController.text,
        'stock_availability': _selectedStockAvailability.value,
        'mrp_in_gst': double.tryParse(_mrpInGstController.text) ?? 0.0,
      };

      if (widget.product != null) {
        await Services()
            .updateProduct(widget.product!.id, productData, _images);
        if (mounted) {
          _showSnackBar('Product updated successfully', false);
          Navigator.pop(context, true);
        }
      } else {
        await Services().createProduct(productData, _images);
        if (mounted) {
          _showSnackBar('Product created successfully', false);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save product: $e', true);
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
          widget.product != null ? 'Edit Product' : 'Create Product',
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
                controller: _codeController,
                label: 'Product Code',
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
              ),
              _buildTextField(
                controller: _descriptionMalayalamController,
                label: 'Description(Mal)',
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
              ListTile(
                title: const Text('Stock Availability'),
                subtitle: Text(_selectedStockAvailability.displayName),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectStockAvailability,
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.divider),
                ),
              ),
              const SizedBox(height: 16),
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
              _buildTextField(
                controller: _mrpInGstController,
                label: 'MRP in GST',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid MRP in GST';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    children: [
                      ..._existingImages
                          .map((e) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        e,
                                        height: 100,
                                        width: 100,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _existingImages.remove(e);
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                  Expanded(
                    child: ImageListPicker(
                      isSingle: true,
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
                  ),
                ],
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
                  onPressed: _isLoading ? null : _saveProduct,
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
                      : Text(widget.product != null
                          ? 'Update Product'
                          : 'Create Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
