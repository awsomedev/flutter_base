import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/enquiry_creation_data.dart';
import '../../models/material_model.dart';
import '../../models/user_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';
import '../../widgets/searchable_picker.dart';

class CreateEnquiryPage extends StatefulWidget {
  const CreateEnquiryPage({super.key});

  @override
  State<CreateEnquiryPage> createState() => _CreateEnquiryPageState();
}

class _CreateEnquiryPageState extends State<CreateEnquiryPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  EnquiryCreationData? _creationData;

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

  // Selected values
  String _selectedPriority = 'medium';
  DateTime? _selectedDeliveryDate;
  User? _selectedManager;
  User? _selectedCarpenter;
  List<MaterialModel> _selectedMaterials = [];

  @override
  void initState() {
    super.initState();
    _loadCreationData();
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

    final result = await showModalBottomSheet<List<MaterialModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<MaterialModel>(
        title: 'Select Materials',
        items: _creationData!.materials,
        getLabel: (material) => material.name,
        getSubtitle: (material) => material.description,
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
          border: const OutlineInputBorder(),
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
      };

      await Services().createEnquiry(data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Enquiry',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _productWidthController,
                            label: 'Width',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
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
                    const SizedBox(height: 24),
                    const Text(
                      'Customer Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        _selectedDeliveryDate == null
                            ? 'Select Delivery Date'
                            : 'Delivery Date: ${_selectedDeliveryDate!.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        _selectedManager == null
                            ? 'Select Manager'
                            : 'Manager: ${_selectedManager!.name}',
                      ),
                      trailing: const Icon(Icons.person),
                      onTap: _selectManager,
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        _selectedCarpenter == null
                            ? 'Select Carpenter'
                            : 'Carpenter: ${_selectedCarpenter!.name}',
                      ),
                      trailing: const Icon(Icons.handyman),
                      onTap: _selectCarpenter,
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        _selectedMaterials.isEmpty
                            ? 'Select Materials'
                            : 'Materials: ${_selectedMaterials.length} selected',
                      ),
                      trailing: const Icon(Icons.category),
                      onTap: _selectMaterials,
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading ? null : _saveEnquiry,
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
                            : const Text('Create Enquiry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
