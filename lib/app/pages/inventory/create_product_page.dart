import 'dart:io';

import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/enquiry_detail_response_model.dart';
import 'package:madeira/app/pages/enquiry/create_enquiry_page.dart';
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
  bool _isOrderLoading = false;
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

  Future<void> createOrder() async {
    context.push(
      () => CreateEnquiryPage(
        withProduct: widget.product,
      ),
    );
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
              prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) return 'Please enter $label';
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF6366F1),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.product != null ? 'Edit Product' : 'Initialize Product',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.05),
                            offset: const Offset(0, 10),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _nameController,
                            label: 'Product Name',
                            icon: Icons.inventory_2_outlined,
                          ),
                          _buildModernTextField(
                            controller: _nameMalayalamController,
                            label: 'Name (Malayalam)',
                            icon: Icons.translate_rounded,
                          ),
                          _buildModernTextField(
                            controller: _codeController,
                            label: 'Product Code',
                            icon: Icons.qr_code_rounded,
                          ),
                          _buildModernTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                          _buildModernTextField(
                            controller: _descriptionMalayalamController,
                            label: 'Description (Malayalam)',
                            icon: Icons.translate_rounded,
                            maxLines: 3,
                          ),
                          const Divider(height: 40, color: Color(0xFFF1F5F9)),
                          const Text(
                            'Specifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _colourController,
                            label: 'Color',
                            icon: Icons.palette_outlined,
                          ),
                          _buildModernTextField(
                            controller: _qualityController,
                            label: 'Quality Standard',
                            icon: Icons.verified_outlined,
                          ),
                          _buildModernTextField(
                            controller: _durabilityController,
                            label: 'Durability',
                            icon: Icons.timer_outlined,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Stock Availability',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectStockAvailability,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6366F1), size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedStockAvailability.displayName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 40, color: Color(0xFFF1F5F9)),
                          const Text(
                            'Pricing & Stock',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _priceController,
                            label: 'Base Price (₹)',
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          _buildModernTextField(
                            controller: _quantityController,
                            label: 'Available Quantity',
                            icon: Icons.numbers_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          _buildModernTextField(
                            controller: _mrpInGstController,
                            label: 'MRP inclusive of GST',
                            icon: Icons.receipt_long_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const Divider(height: 40, color: Color(0xFFF1F5F9)),
                          const Text(
                            'Product Media',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ..._existingImages.map((e) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(e, height: 100, width: 100, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _existingImages.remove(e)),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                Container(
                                  height: 100,
                                  width: 140,
                                  child: ImageListPicker(
                                    isSingle: true,
                                    onAdd: (images, _) => setState(() => _images = images.map((e) => e.file!).toList()),
                                    onRemove: (images, _) => setState(() => _images = images.map((e) => e.file!).toList()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (widget.product != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.2),
                                offset: const Offset(0, 8),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isOrderLoading ? null : createOrder,
                            child: _isOrderLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(
                                    _selectedStockAvailability == StockAvailability.outOfStock
                                        ? 'CREATE ENQUIRY'
                                        : 'CREATE ORDER',
                                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              offset: const Offset(0, 8),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : _saveProduct,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  widget.product != null ? 'SAVE CHANGES' : 'CREATE PRODUCT',
                                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
