import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/process_detail_model.dart';
import 'package:madeira/app/models/material_model.dart';
import 'package:madeira/app/models/user_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/searchable_picker.dart';
import 'package:madeira/app/widgets/quantity_input_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:madeira/app/widgets/image_list_picker.dart';
import 'package:madeira/app/extensions/context_extensions.dart';

class ProcessDetailPage extends StatefulWidget {
  final int processDetailsId;

  const ProcessDetailPage({
    Key? key,
    required this.processDetailsId,
  }) : super(key: key);

  @override
  State<ProcessDetailPage> createState() => _ProcessDetailPageState();
}

class _ProcessDetailPageState extends State<ProcessDetailPage> {
  late Future<ProcessDetailResponse> _detailFuture;
  List<MaterialModel> _materials = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadMaterials();
  }

  void _loadDetails() {
    _detailFuture = Services().getProcessDetail(widget.processDetailsId);
  }

  Future<void> _loadMaterials() async {
    try {
      _materials = await Services().getMaterials();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading materials: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showMaterialPicker() async {
    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No materials available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<MaterialModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<MaterialModel>(
        title: 'Select Materials',
        items: _materials,
        getLabel: (material) => material.name,
        getSubtitle: (material) =>
            '${material.description} - ₹${material.price}',
        allowMultiple: false,
      ),
    );

    if (result != null) {
      List<Future<void>> futures = [];

      final material = result;
      final quantity = await showDialog<int>(
        context: context,
        builder: (context) => QuantityInputDialog(material: material),
      );

      if (quantity != null) {
        futures.add(
          Services()
              .createProcessMaterial(
            processDetailsId: widget.processDetailsId,
            materialId: material.id,
            quantity: quantity,
          )
              .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${material.name} successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add ${material.name}: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          }),
        );
      }

      if (futures.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        try {
          await Future.wait(futures);
          _loadDetails(); // Reload the page data
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  Future<void> _showVerificationImagePicker(BuildContext context) async {
    List<File>? selectedImages;
    List<ImageItem> currentImages = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please select images for approval',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ImageListPicker(
                onAdd: (images, newImage) {
                  currentImages = images;
                  selectedImages = currentImages
                      .where((item) => item.isFile)
                      .map((item) => item.file!)
                      .toList();
                },
                onRemove: (images, removedImage) {
                  currentImages = images;
                  selectedImages = currentImages
                      .where((item) => item.isFile)
                      .map((item) => item.file!)
                      .toList();
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (selectedImages != null && selectedImages!.isNotEmpty) {
                      Navigator.pop(context, selectedImages);
                    } else {
                      context.showSnackBar(
                        'Please select at least one image',
                        backgroundColor: Colors.red,
                      );
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedImages != null && selectedImages!.isNotEmpty) {
      // Show confirmation dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text(
              'Are you sure you want to submit these images for verification?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (shouldProceed == true && context.mounted) {
        try {
          await Services().sendProcessVerificationImages(
              widget.processDetailsId, selectedImages!);
          if (context.mounted) {
            context.showSnackBar(
              'Images submitted successfully',
              backgroundColor: Colors.green,
            );
          }
        } catch (e) {
          if (context.mounted) {
            context.showSnackBar(
              'Failed to submit images: $e',
              backgroundColor: Colors.red,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Details'),
      ),
      body: FutureBuilder<ProcessDetailResponse>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: _loadDetails,
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final data = snapshot.data!.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(
                  data.orderData.images
                      .where((e) => e.id != null && e.image != null)
                      .map((e) => ProcessImage(id: e.id!, image: e.image!))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _buildProductDetails(data.orderData),
                const SizedBox(height: 20),
                _buildProcessDetails(data.processDetails),
                const SizedBox(height: 20),
                _buildManagerDetails(data.mainManager, data.processManager),
                const SizedBox(height: 20),
                _buildWorkersDetails(data.workersData),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showMaterialPicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Materials'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showVerificationImagePicker(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send completion request'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<ProcessImage> images) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.8,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
          ),
          items: images.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image.image.toImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error_outline),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductDetails(ProcessOrderData order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Product Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order.overDue
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.overDue ? 'OVERDUE' : 'ON TIME',
                    style: TextStyle(
                      color:
                          order.overDue ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', order.productName),
            _buildDetailRow('Description', order.productDescription),
            _buildDetailRow('Status', order.status.toUpperCase()),
            _buildDetailRow('Priority', order.priority.toUpperCase()),
            _buildDetailRow(
              'Dimensions',
              '${order.productLength}x${order.productWidth}x${order.productHeight}',
            ),
            _buildDetailRow('Finish', order.finish),
            _buildDetailRow('Event', order.event),
            if (order.estimatedDeliveryDate != null)
              _buildDetailRow(
                'Estimated Delivery',
                DateFormat('dd MMM yyyy').format(order.estimatedDeliveryDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessDetails(ProcessDetails details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Process Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Status', details.processStatus.toUpperCase()),
            if (details.expectedCompletionDate != null)
              _buildDetailRow(
                'Expected Completion',
                DateFormat('dd MMM yyyy')
                    .format(details.expectedCompletionDate!),
              ),
            if (details.completionDate != null)
              _buildDetailRow(
                'Completion Date',
                DateFormat('dd MMM yyyy').format(details.completionDate!),
              ),
            if (details.requestAcceptedDate != null)
              _buildDetailRow(
                'Request Accepted',
                DateFormat('dd MMM yyyy').format(details.requestAcceptedDate!),
              ),
            if (details.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Process Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.8,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                ),
                items: details.images.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image.image.toImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error_outline),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManagerDetails(User mainManager, User processManager) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Managers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Main Manager',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildDetailRow('Name', mainManager.name ?? 'N/A'),
            _buildDetailRow('Phone', mainManager.phone ?? 'N/A'),
            const SizedBox(height: 16),
            const Text(
              'Process Manager',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildDetailRow('Name', processManager.name ?? 'N/A'),
            _buildDetailRow('Phone', processManager.phone ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersDetails(List<User> workers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.name ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              worker.phone ?? 'N/A',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
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
}
