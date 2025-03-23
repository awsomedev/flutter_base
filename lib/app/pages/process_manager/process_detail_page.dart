import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/process_detail_model.dart';
import 'package:madeira/app/models/material_model.dart';
import 'package:madeira/app/models/user_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/audio_player.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
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
  final String processName;

  const ProcessDetailPage({
    Key? key,
    required this.processDetailsId,
    required this.processName,
  }) : super(key: key);

  @override
  State<ProcessDetailPage> createState() => _ProcessDetailPageState();
}

class _ProcessDetailPageState extends State<ProcessDetailPage> {
  ProcessDetailResponse? _detailFuture;
  List<MaterialModel> _materials = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadMaterials();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _detailFuture =
          await Services().getProcessDetail(widget.processDetailsId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading details: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  bool _isPaused = false;
  int _orderId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.processName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) =>
                AlertDialog(
              title: Text(_isPaused ? 'Resume Process' : 'Pause Process'),
              content: Text(_isPaused
                  ? 'Are you sure you want to resume the process?'
                  : 'Are you sure you want to pause the process?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_isPaused) {
                      try {
                        await Services().resumeProcess(_orderId);
                        context.showSnackBar(
                          'Process resumed successfully',
                          backgroundColor: Colors.green,
                        );
                        _loadDetails();
                      } catch (e) {
                        context.showSnackBar(
                          'Failed to resume process: $e',
                          backgroundColor: Colors.red,
                        );
                      }
                    } else {
                      try {
                        await Services().pauseProcess(_orderId);
                        context.showSnackBar(
                          'Process paused successfully',
                          backgroundColor: Colors.green,
                        );
                        _loadDetails();
                      } catch (e) {
                        context.showSnackBar(
                          'Failed to pause process: $e',
                          backgroundColor: Colors.red,
                        );
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text(_isPaused ? 'Resume' : 'Pause'),
                ),
              ],
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const LoadingWidget();
          }

          if (_detailFuture == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          if (_detailFuture == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final data = _detailFuture!.data;
          _isPaused =
              data.processDetails.processStatus.toLowerCase() == 'paused';
          _orderId = data.orderData.id;
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
                for (var audio in data.orderData.audio)
                  AudioPlayer(audioUrl: audio.audio.toString().toUrl),
                const SizedBox(height: 20),
                _buildProcessDetails(data.processDetails, widget.processName),
                const SizedBox(height: 20),
                _buildProductDetails(data.orderData),
                const SizedBox(height: 20),
                _buildManagerDetails(data.mainManager, data.processManager),
                const SizedBox(height: 20),
                _buildWorkersDetails(data.workersData),
                const SizedBox(height: 20),
                _buildUsedMaterials(data.usedMaterials),
                const SizedBox(height: 20),
                if (data.processDetails.processStatus.toLowerCase() ==
                    'in_progress')
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
                if (data.processDetails.processStatus.toLowerCase() ==
                    'in_progress')
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
                const Expanded(
                  child: Text(
                    'Product Details',
                    style: TextStyle(
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

  Widget _buildProcessDetails(ProcessDetails details, String processName) {
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
            _buildDetailRow('Process', processName),
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

  Widget _buildUsedMaterials(List<UsedMaterial> materials) {
    if (materials.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Used Materials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'No materials used yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Used Materials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ₹${materials.fold(0.0, (sum, material) => sum + (material.materialUsed.totalPrice ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final material = materials[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.material.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                material.material.nameMal,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                bool? res = await ConfirmationDialog.show(
                                  title: 'Delete Material',
                                  message:
                                      'Are you sure you want to delete this material?',
                                  context: context,
                                );
                                if (res == true) {
                                  await Services().deleteProcessMaterial(
                                    processDetailsId: widget.processDetailsId,
                                    materialId: material.material.id,
                                  );
                                  if (context.mounted) {
                                    context.showSnackBar(
                                      'Material deleted successfully',
                                      backgroundColor: Colors.green,
                                    );
                                    setState(() {});
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                material.material.stockAvailability
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity: ${material.materialUsed.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Price: ₹${material.materialUsed.materialPrice}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          'Total: ₹${material.materialUsed.totalPrice}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      material.material.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      material.material.descriptionMal,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
