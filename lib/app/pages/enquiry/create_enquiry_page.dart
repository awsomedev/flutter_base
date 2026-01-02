import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madeira/app/models/category_model.dart';
import 'package:madeira/app/models/product_model.dart';
import 'package:madeira/app/models/decoration_enquiry.dart';
import 'package:madeira/app/models/decorations_response_model.dart';
import 'package:madeira/app/widgets/audio_player.dart';
import 'package:madeira/app/widgets/image_list_picker.dart';
import '../../models/enquiry_creation_data.dart';
import '../../models/material_model.dart';
import '../../models/user_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';
import '../../widgets/searchable_picker.dart';
import '../../widgets/audio_recorder.dart';
import 'package:madeira/app/models/enquiry_detail_response_model.dart'
    as enquiry;

class CreateEnquiryPage extends StatefulWidget {
  const CreateEnquiryPage({super.key, this.orderData, this.withProduct});
  final enquiry.OrderData? orderData;
  final ProductModel? withProduct;

  @override
  State<CreateEnquiryPage> createState() => _CreateEnquiryPageState();
}

class _CreateEnquiryPageState extends State<CreateEnquiryPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  EnquiryCreationData? _creationData;
  List<DecorationResponse> _decorationEnquiry = [];

  // Form controllers
  final _productNameController = TextEditingController();
  final _productNameMalController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productDescriptionMalController = TextEditingController();
  final _productLengthController = TextEditingController();
  final _productHeightController = TextEditingController();
  final _productWidthController = TextEditingController();
  final _finishController = TextEditingController();
  final _eventController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _estimatedPriceController = TextEditingController();
  List<DecorationEnquiry> items = [];

  // Selected values
  String _selectedPriority = 'medium';
  DateTime? _selectedDeliveryDate;
  User? _selectedManager;
  User? _selectedCarpenter;
  List<MaterialModel> _selectedMaterials = [];
  List<File> _selectedImages = [];
  List<File> _audioRecording = [];

  // void _addNewItem(DecorationResponse enquiryType, User user, String note) {
  //   setState(() {
  //     items.add(DecorationEnquiry(
  //       enquiry: enquiryType,
  //       enquiryUser: user,
  //       note: note,
  //     ));
  //   });
  // }

  void _removeItem(int id) {
    setState(() {
      items.removeWhere((item) => item.enquiry.id == id);
    });
  }

  Future<void> _addNewItemWithDialog() async {
    final textController = TextEditingController();
    User? selectedUser;
    DecorationResponse? selectedEnquiry;

    Future<void> selectUser(BuildContext dialogContext) async {
      if (!mounted) return;

      if (_creationData == null || _creationData!.managers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No users available')),
        );
        return;
      }

      final result = await showModalBottomSheet<User?>(
        context: dialogContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SearchablePicker<User>(
          title: 'Select User',
          items: _creationData!.managers,
          getLabel: (user) => user.name ?? 'Unnamed User',
          getSubtitle: (user) => user.phone ?? 'No phone number',
        ),
      );

      if (result != null && mounted) {
        selectedUser = result;
        (dialogContext as Element).markNeedsBuild();
      }
    }

    Future<void> selectDecoration(BuildContext dialogContext) async {
      if (!mounted) return;

      if (_decorationEnquiry.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No decoration enquiries available')),
        );
        return;
      }

      final result = await showModalBottomSheet<DecorationResponse?>(
        context: dialogContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SearchablePicker<DecorationResponse>(
          title: 'Select Decoration',
          items: _decorationEnquiry,
          getLabel: (enq) => enq.enquiryName,
        ),
      );

      if (result != null && mounted) {
        selectedEnquiry = result;
        (dialogContext as Element).markNeedsBuild();
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Add New Item",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: context.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          selectedEnquiry?.enquiryName ??
                              'Select decoration enquiry',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: selectedEnquiry != null
                                        ? const Color(0xFF2D3748)
                                        : Colors.grey[600],
                                  ),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF667eea)),
                        onTap: () => selectDecoration(dialogContext),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          selectedUser?.name ?? 'Select User',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: selectedUser != null
                                        ? const Color(0xFF2D3748)
                                        : Colors.grey[600],
                                  ),
                        ),
                        subtitle: selectedUser != null
                            ? Text(selectedUser!.phone ?? '')
                            : null,
                        trailing: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF667eea)),
                        onTap: () => selectUser(dialogContext),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: "Enter note",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF667eea)),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    if (selectedUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a user')),
                      );
                      return;
                    }
                    if (textController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a note')),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      if (selectedUser == null || selectedEnquiry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing required selections')),
        );
        return;
      }

      setState(() {
        items.add(DecorationEnquiry(
          enquiry: selectedEnquiry!,
          enquiryUser: selectedUser!,
          note: textController.text.trim(),
        ));
      });
    }
  }

  Future<void> _loadOrderData() async {
    _productNameController.text = widget.orderData?.productName ?? '';
    _productNameMalController.text = widget.orderData?.productNameMal ?? '';
    _productDescriptionController.text =
        widget.orderData?.productDescription ?? '';
    _productDescriptionMalController.text =
        widget.orderData?.productDescriptionMal ?? '';
    _productLengthController.text =
        widget.orderData?.productLength?.toString() ?? '';
    _productWidthController.text =
        widget.orderData?.productWidth?.toString() ?? '';
    _productHeightController.text =
        widget.orderData?.productHeight?.toString() ?? '';
    _finishController.text = widget.orderData?.finish ?? '';
    _eventController.text = widget.orderData?.event ?? '';
    _customerNameController.text = widget.orderData?.customerName ?? '';
    _contactNumberController.text = widget.orderData?.contactNumber ?? '';
    _whatsappNumberController.text = widget.orderData?.whatsappNumber ?? '';
    _emailController.text = widget.orderData?.email ?? '';
    _addressController.text = widget.orderData?.address ?? '';
    _estimatedPriceController.text =
        widget.orderData?.estimatedPrice?.toString() ?? '';
    _selectedPriority = widget.orderData?.priority ?? 'medium';
    _selectedDeliveryDate = widget.orderData?.estimatedDeliveryDate;
    _estimatedPriceController.text =
        widget.orderData?.estimatedPrice?.toString() ?? '';
  }

  Future<void> _loadProductData() async {
    _productNameController.text = widget.withProduct?.name ?? '';
    _productNameMalController.text = widget.withProduct?.nameMal ?? '';
    _productDescriptionController.text = widget.withProduct?.description ?? '';
    _productDescriptionMalController.text =
        widget.withProduct?.descriptionMal ?? '';
    _estimatedPriceController.text = widget.withProduct?.price.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();

    _loadCreationData();
    _loadDecorationData();

    if (widget.withProduct != null) {
      _loadProductData();
    }
    if (widget.orderData != null) {
      _loadOrderData();
    }
  }

  Future<void> _loadDecorationData() async {
    try {
      final decorations = await Services().fetchDecorations();
      setState(() {
        _decorationEnquiry = decorations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadCreationData() async {
    try {
      final response = await Services().getEnquiryCreationData();
      setState(() {
        _creationData = EnquiryCreationData.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectManager() async {
    if (_creationData == null) return;

    final result = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<User>(
        title: 'Select Manager',
        items: _creationData!.managers,
        getLabel: (user) => user.name ?? '',
        getSubtitle: (user) => user.phone ?? '',
      ),
    );

    if (result != null) {
      setState(() {
        _selectedManager = result;
      });
    }
  }

  Future<void> _selectCarpenter() async {
    if (_creationData == null) return;

    final result = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<User>(
        title: 'Select Carpenter',
        items: _creationData!.managers
            .where((user) => !(user.isAdmin ?? false))
            .toList(),
        getLabel: (user) => user.name ?? '',
        getSubtitle: (user) => user.phone ?? '',
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCarpenter = result;
      });
    }
  }

  Future<void> _selectMaterials() async {
    if (_creationData == null) return;

    final categoryResult = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<Category>(
        title: 'Select Category',
        items: _creationData!.categories,
        getLabel: (category) => category.name,
        getSubtitle: (category) => category.description,
        allowMultiple: false,
        selectedItems: const [],
      ),
    );

    final result = await showModalBottomSheet<List<MaterialModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<MaterialModel>(
        title: 'Select Materials',
        items: categoryResult?.id == 0
            ? _creationData!.materials
            : _creationData!.materials
                .where((material) => material.category == categoryResult?.id)
                .toList(),
        getLabel: (material) => material.name ?? '',
        getSubtitle: (material) => material.description ?? '',
        allowMultiple: true,
        selectedItems: _selectedMaterials,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMaterials = result;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDeliveryDate = picked;
      });
    }
  }

  Future<void> _saveEnquiry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a manager'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedCarpenter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a carpenter'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one material'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedDeliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select delivery date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_estimatedPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter estimated price'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'product_name': _productNameController.text,
        'product_name_mal': _productNameMalController.text,
        'product_description': _productDescriptionController.text,
        'product_description_mal': _productDescriptionMalController.text,
        'product_length': double.parse(_productLengthController.text),
        'product_height': double.parse(_productHeightController.text),
        'product_width': double.parse(_productWidthController.text),
        'finish': _finishController.text,
        'event': _eventController.text,
        'customer_name': _customerNameController.text,
        'contact_number': _contactNumberController.text,
        'whatsapp_number': _whatsappNumberController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'priority': _selectedPriority,
        'estimated_delivery_date':
            _selectedDeliveryDate!.toIso8601String().split('T')[0],
        'main_manager_id': _selectedManager!.id,
        'carpenter_id': _selectedCarpenter!.id,
        'material_ids': _selectedMaterials.map((m) => m.id).toList(),
        'estimated_price': double.parse(_estimatedPriceController.text),
        'enquiries': jsonEncode(items
            .map((e) => {
                  'enquiry_type_id': e.enquiry.id,
                  'enquiry_user_id': e.enquiryUser.id,
                  'about_enquiry': e.note
                })
            .toList())
      };
      log("qwerty ${data}");

      final files = {
        'reference_image': _selectedImages,
      };

      if (_audioRecording.isNotEmpty) {
        files['reference_audios'] = _audioRecording;
      }

      await Services().createEnquiry(data, files);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enquiry created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create enquiry: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF667eea)
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                isSelected ? const Color(0xFF667eea) : const Color(0xFF2D3748),
          ),
        ),
        trailing: Icon(
          icon,
          color: isSelected ? const Color(0xFF667eea) : const Color(0xFF6B7280),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.orderData == null ? 'Create Enquiry' : 'Edit Enquiry',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Product Details', Icons.inventory_2),
                    _buildTextField(
                      controller: _productNameController,
                      label: 'Product Name',
                    ),
                    _buildTextField(
                      controller: _productNameMalController,
                      label: 'Product Name (Malayalam)',
                      isRequired: false,
                    ),
                    _buildTextField(
                      controller: _productDescriptionController,
                      label: 'Description',
                      maxLines: 3,
                    ),
                    _buildTextField(
                      controller: _productDescriptionMalController,
                      label: 'Description (Malayalam)',
                      maxLines: 3,
                      isRequired: false,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _productLengthController,
                            label: 'Length',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _productWidthController,
                            label: 'Width',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _productHeightController,
                            label: 'Height',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: _finishController,
                      label: 'Finish',
                    ),
                    _buildTextField(
                      controller: _eventController,
                      label: 'Event',
                    ),
                    _buildTextField(
                      controller: _estimatedPriceController,
                      label: 'Estimated Price',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Customer Details', Icons.person),
                    _buildTextField(
                      controller: _customerNameController,
                      label: 'Customer Name',
                    ),
                    _buildTextField(
                      controller: _contactNumberController,
                      label: 'Contact Number',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _whatsappNumberController,
                      label: 'WhatsApp Number',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      isRequired: false,
                    ),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Order Details', Icons.shopping_cart),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['low', 'medium', 'high', 'urgent']
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPriority = value;
                            });
                          }
                        },
                      ),
                    ),
                    _buildSelectableTile(
                      title: _selectedDeliveryDate == null
                          ? 'Select Delivery Date'
                          : 'Delivery Date: ${_selectedDeliveryDate!.toLocal().toString().split(' ')[0]}',
                      icon: Icons.calendar_today,
                      onTap: _selectDate,
                      isSelected: _selectedDeliveryDate != null,
                    ),
                    _buildSelectableTile(
                      title: _selectedManager == null
                          ? 'Select Manager'
                          : 'Manager: ${_selectedManager!.name}',
                      icon: Icons.person,
                      onTap: _selectManager,
                      isSelected: _selectedManager != null,
                    ),
                    _buildSelectableTile(
                      title: _selectedCarpenter == null
                          ? 'Select Carpenter'
                          : 'Carpenter: ${_selectedCarpenter!.name}',
                      icon: Icons.handyman,
                      onTap: _selectCarpenter,
                      isSelected: _selectedCarpenter != null,
                    ),
                    _buildSelectableTile(
                      title: _selectedMaterials.isEmpty
                          ? 'Select Materials'
                          : 'Materials: ${_selectedMaterials.length} selected',
                      icon: Icons.category,
                      onTap: _selectMaterials,
                      isSelected: _selectedMaterials.isNotEmpty,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.design_services,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Decoration Enquiries',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _addNewItemWithDialog,
                            icon: const Icon(Icons.add, color: Colors.white),
                            tooltip: 'Add Item',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    items.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No items added yet",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    item.enquiry.enquiryName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                size: 16,
                                                color: Color(0xFF6B7280)),
                                            const SizedBox(width: 6),
                                            Text(
                                              "User: ${item.enquiryUser.name}",
                                              style: const TextStyle(
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.note,
                                                size: 16,
                                                color: Color(0xFF6B7280)),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                "Note: ${item.note}",
                                                style: const TextStyle(
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeItem(item.enquiry.id),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Voice Note', Icons.mic),
                    _audioRecording.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              for (File audio in _audioRecording)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AudioPlayer(
                                          audioFile: audio,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _audioRecording.remove(audio);
                                            });
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                            ],
                          ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: AudioRecorder(
                        onRecordingComplete: (audioFile) {
                          setState(() {
                            _audioRecording = [audioFile];
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Product Images', Icons.photo_library),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ImageListPicker(
                        onAdd: (allImages, _) {
                          setState(() {
                            _selectedImages =
                                allImages.map((e) => e.file!).toList();
                          });
                        },
                        onRemove: (removedImages, _) {
                          setState(() {
                            _selectedImages =
                                removedImages.map((e) => e.file!).toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _saveEnquiry,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.save,
                                          color: Colors.white, size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.orderData == null
                                            ? 'Create Enquiry'
                                            : 'Update Enquiry',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
