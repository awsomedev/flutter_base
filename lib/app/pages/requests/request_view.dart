import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/request_detail_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RequestViewPage extends StatefulWidget {
  final int orderId;

  const RequestViewPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<RequestViewPage> createState() => _RequestViewPageState();
}

class _RequestViewPageState extends State<RequestViewPage> {
  late Future<RequestDetail> _requestDetailFuture;
  final Map<int, Map<String, TextEditingController>> _dimensionControllers = {};
  final Map<int, String> _dimentionType = {};
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestDetailFuture = Services().getRequestDetail(widget.orderId);
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controllers in _dimensionControllers.values) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }

  Future<void> _updateDimensions(
      BuildContext context, List<MaterialWithEnquiry> materials) async {
    // Validate all fields are filled
    bool hasEmptyFields = false;
    String emptyFieldMaterial = '';

    for (var material in materials) {
      final controllers = _dimensionControllers[material.id];
      if (controllers == null) continue;
      final type = _dimentionType[material.id];

      if (type == 'round_log' &&
          (controllers['length']!.text.isEmpty ||
              controllers['gridth']!.text.isEmpty)) {
        hasEmptyFields = true;
        emptyFieldMaterial = material.name;
        break;
      }

      if (type == 'rectangular_wood' &&
          (controllers['length']!.text.isEmpty ||
              controllers['width']!.text.isEmpty ||
              controllers['thickness']!.text.isEmpty ||
              controllers['no_of_pieces']!.text.isEmpty)) {
        hasEmptyFields = true;
        emptyFieldMaterial = material.name;
        break;
      }
    }

    if (hasEmptyFields) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all dimensions for $emptyFieldMaterial'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    bool? isAccepted = await ConfirmationDialog.show(
        context: context,
        title: 'Do you want to update',
        message: 'You can change when ever needed');

    if (isAccepted != true) {
      return;
    }

    // Prepare data for API
    final List<Map<String, dynamic>> updateData = materials.map((material) {
      final controllers = _dimensionControllers[material.id]!;

      return {
        'order_id': widget.orderId,
        'material_id': material.id,
        'type': _dimentionType[material.id],
        'material_length': double.parse(controllers['length']!.text),
        'material_width': double.tryParse(controllers['width']!.text) ?? 0,
        'material_gridth': double.tryParse(controllers['gridth']!.text) ?? 0,
        'material_no_of_pieces':
            double.tryParse(controllers['no_of_pieces']!.text) ?? 0,
        'material_thickness':
            double.tryParse(controllers['thickness']!.text) ?? 0,
      };
    }).toList();

    log('$updateData');

    try {
      await Services().updateRequestDimensions(updateData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dimensions updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh the data
        setState(() {
          _requestDetailFuture = Services().getRequestDetail(widget.orderId);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update dimensions: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleFinishRequest(BuildContext context) async {
    bool? isAccepted = await ConfirmationDialog.show(
      context: context,
      title: 'Finish Request',
      message:
          'Are you sure you want to finish this request? This action cannot be undone.',
      confirmText: 'Finish',
      cancelText: 'Cancel',
    );

    if (isAccepted != true) {
      return;
    }

    try {
      await Services().finishRequest(widget.orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request finished successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh the data
        setState(() {
          _requestDetailFuture = Services().getRequestDetail(widget.orderId);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to finish request: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: FutureBuilder<RequestDetail>(
        future: _requestDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _requestDetailFuture =
                      Services().getRequestDetail(widget.orderId);
                });
              },
            );
          }

          final request = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductSection(request),
                const SizedBox(height: 24),
                _buildMaterialsSection(
                    request.materials, request.status == 'completed'),
                const SizedBox(height: 16),
                if (request.status != 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateDimensions(context, request.materials),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                      ),
                      child: const Text(
                        'Update Dimensions',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (request.status != 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleFinishRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                      ),
                      child: const Text(
                        'Finish request',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection(RequestDetail request) {
    return Column(
      children: [
        if (request.images.isNotEmpty) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: request.images.length > 1,
                  autoPlayInterval: const Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: request.images.map((image) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image.image.toImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (request.images.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: request.images.asMap().entries.map((entry) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            _currentImageIndex == entry.key ? 0.9 : 0.4,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Name', request.productName),
                if (request.productNameMal != null)
                  _buildDetailRow('Name (Malayalam)', request.productNameMal!),
                if (request.productDescription != null)
                  _buildDetailRow('Description', request.productDescription!),
                if (request.productDescriptionMal != null)
                  _buildDetailRow('Description (Malayalam)',
                      request.productDescriptionMal!),
                const SizedBox(height: 16),
                const Text(
                  'Dimensions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child:
                          _buildDimensionField('Length', request.productLength),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          _buildDimensionField('Width', request.productWidth),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          _buildDimensionField('Height', request.productHeight),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Finish', request.finish),
                _buildDetailRow('Event', request.event),
                _buildDetailRow('Priority', request.priority),
                _buildDetailRow('Status', request.status),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsSection(
      List<MaterialWithEnquiry> materials, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Materials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: materials.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              _buildMaterialCard(materials[index], isCompleted),
        ),
      ],
    );
  }

  Widget _buildMaterialCard(MaterialWithEnquiry material, bool isCompleted) {
    // Initialize controllers if not already done
    if (!_dimensionControllers.containsKey(material.id)) {
      _dimensionControllers[material.id] = {
        'length': TextEditingController(
          text: material.enquiryData.materialLength?.toString() ?? '',
        ),
        'width': TextEditingController(
          text: material.enquiryData.materialWidth?.toString() ?? '',
        ),
        'thickness': TextEditingController(
          text: '',
        ),
        'no_of_pieces': TextEditingController(
          text: '',
        ),
        'gridth': TextEditingController(
          text: '',
        ),
      };
    }
    if (!_dimentionType.containsKey(material.id)) {
      _dimentionType[material.id] = 'round_log';
    }

    final controllers = _dimensionControllers[material.id]!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              material.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (material.nameMal != null) ...[
              const SizedBox(height: 4),
              Text(
                material.nameMal,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(material.description),
            if (material.descriptionMal != null) ...[
              const SizedBox(height: 4),
              Text(
                material.descriptionMal,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildDetailRow('Color', material.colour),
            _buildDetailRow('Quality', material.quality),
            _buildDetailRow('Durability', material.durability),
            const SizedBox(height: 16),
            const Text(
              'Required Dimensions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _dimentionType[material.id],
              decoration: const InputDecoration(
                labelText: 'Select Dimentions',
                border: OutlineInputBorder(),
              ),
              items: ['round_log', 'rectangular_wood']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(
                          priority.replaceAll('_', ' ').toUpperCase(),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _dimentionType[material.id] = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            if (_dimentionType[material.id] == 'round_log')
              Row(
                children: [
                  Expanded(
                    child: _buildDimensionTextField(
                        'Length', controllers['length']!,
                        isDisabled: isCompleted),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDimensionTextField(
                        'Gridth', controllers['gridth']!,
                        isDisabled: isCompleted, suffixText: 'inch'),
                  ),
                ],
              ),
            if (_dimentionType[material.id] == 'rectangular_wood')
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDimensionTextField(
                            'Length', controllers['length']!,
                            isDisabled: isCompleted),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDimensionTextField(
                            'Width', controllers['width']!,
                            isDisabled: isCompleted, suffixText: 'inch'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDimensionTextField(
                            'Thickness', controllers['thickness']!,
                            isDisabled: isCompleted, suffixText: 'inch'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDimensionTextField(
                            'Number of pieces', controllers['no_of_pieces']!,
                            isDisabled: isCompleted, suffixText: ''),
                      ),
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionTextField(
      String label, TextEditingController controller,
      {Function(String)? onChanged,
      bool isDisabled = false,
      String suffixText = 'ft'}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: onChanged,
                  readOnly: isDisabled,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    hintText: '0.0',
                    suffixText: suffixText,
                    suffixStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionField(String label, double? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'ft',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
