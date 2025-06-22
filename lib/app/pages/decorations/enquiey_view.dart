import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/decoration_enquiry_detail_response.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EnquiryViewPage extends StatefulWidget {
  final int enquiryId;

  const EnquiryViewPage({Key? key, required this.enquiryId}) : super(key: key);

  @override
  State<EnquiryViewPage> createState() => _EnquiryViewPageState();
}

class _EnquiryViewPageState extends State<EnquiryViewPage> {
  late Future<DecorationEnquiryDetailResponse> _requestDetailFuture;
  final _descriptionController = TextEditingController();
  final _constController = TextEditingController();
  final _daysController = TextEditingController();

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestDetailFuture = Services().getDecorEnquiryDetail(widget.enquiryId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updateEnquiryDetails(BuildContext context) async {
    // Validate all fields are filled
    bool hasEmptyFields = false;

    hasEmptyFields = _descriptionController.text.isEmpty ||
        _constController.text.isEmpty ||
        _daysController.text.isEmpty;

    if (hasEmptyFields) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    bool? isAccepted = await ConfirmationDialog.show(
        context: context, title: 'Do you want to submit', message: '');

    if (isAccepted != true) {
      return;
    }

    Map<String, dynamic> updateData = {
      "enquiry_description": _descriptionController.text,
      "completion_time": _daysController.text,
      "cost": _constController.text
    };

    try {
      await Services().updateEnquiryDetails(widget.enquiryId, updateData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dimensions updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update enquiry'),
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
      body: FutureBuilder<DecorationEnquiryDetailResponse>(
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
                      Services().getDecorEnquiryDetail(widget.enquiryId);
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
                _buildProductSection(request.orderData),
                const SizedBox(height: 24),
                _buildEnquirySection(request.enquiryData),
                const SizedBox(height: 24),
                if (request.enquiryData.status == 'checking')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateEnquiryDetails(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[500],
                      ),
                      child: const Text(
                        'Update Enquiry',
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

  Widget _buildProductSection(DecorationOrderData orderData) {
    return Column(
      children: [
        if (orderData.referenceImage.isNotEmpty) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: orderData.referenceImage.length > 1,
                  autoPlayInterval: const Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: orderData.referenceImage.map((image) {
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
              if (orderData.referenceImage.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        orderData.referenceImage.asMap().entries.map((entry) {
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
                _buildDetailRow('Name', orderData.productName),
                if (orderData.productNameMal != null)
                  _buildDetailRow(
                      'Name (Malayalam)', orderData.productNameMal!),
                if (orderData.productDescription != null)
                  _buildDetailRow('Description', orderData.productDescription!),
                if (orderData.productDescriptionMal != null)
                  _buildDetailRow('Description (Malayalam)',
                      orderData.productDescriptionMal!),
                const SizedBox(height: 16),
                _buildDetailRow('Finish', orderData.finish),
                const SizedBox(height: 16),
                const Text(
                  'Product Dimensions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDimensionField(
                          'Length', orderData.productLength),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          _buildDimensionField('Width', orderData.productWidth),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDimensionField(
                          'Height', orderData.productHeight),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Materials',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderData.materials.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        Text(orderData.materials[index].name)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsSection(List<DecorMaterial> materials) {
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
          itemBuilder: (context, index) => _buildMaterialCard(materials[index]),
        ),
      ],
    );
  }

  Widget _buildMaterialCard(DecorMaterial material) {
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
            // if (material.name != null) ...[
            //   const SizedBox(height: 4),
            //   Text(
            //     material.name,
            //     style: const TextStyle(
            //       fontSize: 14,
            //       color: AppColors.textSecondary,
            //     ),
            //   ),
            // ],
            // const SizedBox(height: 8),
            // Text(material.description),
            // if (material.descriptionMal != null) ...[
            //   const SizedBox(height: 4),
            //   Text(
            //     material.descriptionMal,
            //     style: const TextStyle(
            //       fontSize: 14,
            //       color: AppColors.textSecondary,
            //     ),
            //   ),
            // ],
            // const SizedBox(height: 16),
            // _buildDetailRow('Color', material.colour),
            // _buildDetailRow('Quality', material.quality),
            // _buildDetailRow('Durability', material.durability),
            // const SizedBox(height: 16),
            // const Text(
            //   'Required Dimensions',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildDimensionTextField(
            //           'Length', controllers['length']!,
            //           isDisabled: isCompleted),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(
            //       child: _buildDimensionTextField(
            //           'Width', controllers['width']!,
            //           isDisabled: isCompleted),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(
            //       child: _buildDimensionTextField(
            //           'Height', controllers['height']!,
            //           isDisabled: isCompleted),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionTextField(
    String label,
    TextEditingController controller, {
    Function(String)? onChanged,
    bool isDisabled = false,
  }) {
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
                    suffixText: 'ft',
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

  Widget _buildEnquirySection(DecorEnquiryData enquiryData) {
    return Column(
      children: [
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
                  'Enquiry',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Name', enquiryData.enquiryType),
                _buildDetailRow('Description', enquiryData.aboutEnquiry),
                _buildDetailRow('Status', enquiryData.status),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _descriptionController,
                    label: 'Enquiry Description',
                    maxLines: 3),
                _buildTextField(
                    controller: _daysController,
                    label: 'Days required',
                    keyboardType: TextInputType.number,
                    maxLines: 1),
                _buildTextField(
                    controller: _constController,
                    keyboardType: TextInputType.number,
                    label: 'Cost',
                    maxLines: 1),
              ],
            ),
          ),
        ),
      ],
    );
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
}
