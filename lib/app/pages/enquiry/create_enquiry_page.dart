import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
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
  const CreateEnquiryPage({super.key, this.orderData});
  final enquiry.OrderData? orderData;

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

  void _addNewItem(DecorationResponse enquiryType, User user, String note) {
    setState(() {
      items.add(DecorationEnquiry(
        enquiry: enquiryType,
        enquiryUser: user,
        note: note,
      ));
    });
  }

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
        context: dialogContext, // Use dialogContext here
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
        // No need for setState here, we'll handle it differently
        selectedUser = result;
        // This will trigger a rebuild of the StatefulBuilder content
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
        context: dialogContext, // Use dialogContext here
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SearchablePicker<DecorationResponse>(
          title: 'Select Decoration',
          items: _decorationEnquiry,
          getLabel: (enq) => enq.enquiryName,
        ),
      );

      if (result != null && mounted) {
        // No need for setState here, we'll handle it differently
        selectedEnquiry = result;
        // This will trigger a rebuild of the StatefulBuilder content
        (dialogContext as Element).markNeedsBuild();
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Add New Item"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      selectedEnquiry?.enquiryName ??
                          'Select decoration enquiry',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: selectedUser != null
                        ? Text(selectedUser!.phone ?? '')
                        : null,
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () => selectDecoration(dialogContext),
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      selectedUser?.name ?? 'Select User',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: selectedUser != null
                        ? Text(selectedUser!.phone ?? '')
                        : null,
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () => selectUser(dialogContext),
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Enter note",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
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
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      if (selectedUser == null || selectedEnquiry == null) {
        // This should theoretically never happen because of your validation
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

    // textController.dispose();
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

  @override
  void initState() {
    super.initState();
    _loadCreationData();
    _loadDecorationData();
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

    final result = await showModalBottomSheet<List<MaterialModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<MaterialModel>(
        title: 'Select Materials',
        items: _creationData!.materials,
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
        'enquiries': items
            .map((e) => {
                  'enquiry_type_id': e.enquiry.id,
                  'enquiry_user_id': e.enquiryUser.id,
                  'about_enquiry': e.note
                })
            .toList()
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.orderData == null ? 'Create Enquiry' : 'Edit Enquiry',
          style: const TextStyle(color: AppColors.textPrimary),
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
                    _buildTextField(
                      controller: _estimatedPriceController,
                      label: 'Estimated Price',
                      keyboardType: TextInputType.number,
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Decoration Enquiries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                            onPressed: _addNewItemWithDialog,
                            icon: const Icon(
                                Icons.add)), // Your button widget here
                      ],
                    ),
                    items.isEmpty
                        ? const Center(child: Text("No items added yet"))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: ListTile(
                                  title:
                                      Text("ID: ${item.enquiry.enquiryName}"),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("User: ${item.enquiryUser.name}"),
                                      Text("Note: ${item.note}"),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () =>
                                        _removeItem(item.enquiry.id),
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 12),
                    const Text(
                      'Voice Note',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _audioRecording.isEmpty
                        ? SizedBox.shrink()
                        : Column(
                            children: [
                              const SizedBox(height: 12),
                              for (File audio in _audioRecording)
                                Row(
                                  children: [
                                    Expanded(
                                      child: AudioPlayer(
                                        audioFile: audio,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _audioRecording.remove(audio);
                                        });
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                    const SizedBox(height: 12),
                    AudioRecorder(
                      onRecordingComplete: (audioFile) {
                        setState(() {
                          _audioRecording = [audioFile];
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ImageListPicker(
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
