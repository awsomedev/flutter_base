import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/category_model.dart';
import 'package:madeira/app/models/process_detail_model.dart' hide Material;
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
  List<Category> _categories = [];
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
      _categories = [
        Category(
          id: 0,
          name: 'All',
          description: 'All',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ...(await Services().getCategories())
      ];
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

    final categoryResult = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<Category>(
        title: 'Select Category',
        items: _categories,
        getLabel: (category) => category.name,
        getSubtitle: (category) => category.description,
        allowMultiple: false,
        selectedItems: const [],
      ),
    );
    final result = await showModalBottomSheet<MaterialModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchablePicker<MaterialModel>(
        title: 'Select Materials',
        items: categoryResult?.id == 0
            ? _materials
            : _materials
                .where((material) => material.category == categoryResult?.id)
                .toList(),
        getLabel: (material) => material.name ?? '',
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
    List<File> selectedImages = [];
    
    final result = await showGeneralDialog<List<File>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * anim1.value),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 36),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Complete Process',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload images for verification and approval',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
                        ImageListPicker(
                          onAdd: (images, newImage) {
                            setModalState(() {
                              selectedImages = images.where((item) => item.isFile).map((item) => item.file!).toList();
                            });
                          },
                          onRemove: (images, removedImage) {
                            setModalState(() {
                              selectedImages = images.where((item) => item.isFile).map((item) => item.file!).toList();
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedImages.isNotEmpty) {
                                      Navigator.pop(context, selectedImages);
                                    } else {
                                      context.showSnackBar('Select at least one image', backgroundColor: const Color(0xFFEF4444));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        await Services().sendProcessVerificationImages(widget.processDetailsId, result);
        if (mounted) {
          context.showSnackBar('Process submitted for approval', backgroundColor: const Color(0xFF10B981));
          _loadDetails();
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar('Failed to submit: $e', backgroundColor: const Color(0xFFEF4444));
        }
      }
    }
  }

  bool _isPaused = false;
  int _orderId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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

          final data = _detailFuture!.data;
          _isPaused = data.processDetails.processStatus.toLowerCase() == 'paused';
          _orderId = data.orderData.id;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 110.0,
                    floating: false,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [StretchMode.zoomBackground],
                      title: Text(
                        widget.processName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                      ),
                      centerTitle: true,
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeader('Product Overview'),
                        _buildImageCarousel(
                          data.orderData.images
                              .where((e) => e.id != null && e.image != null)
                              .map((e) => ProcessImage(id: e.id!, image: e.image!))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        for (var audio in data.orderData.audio)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: AudioPlayer(audioUrl: audio.audio.toString().toUrl),
                          ),
                        _buildProcessDetailsCard(data.processDetails, widget.processName),
                        const SizedBox(height: 20),
                        _buildProductDetailsCard(data.orderData),
                        const SizedBox(height: 20),
                        _buildManagerDetailsCard(data.mainManager, data.processManager),
                        const SizedBox(height: 20),
                        _buildWorkersDetailsCard(data.workersData),
                        const SizedBox(height: 20),
                        _buildUsedMaterialsCard(data.usedMaterials),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              ),
              if (data.processDetails.processStatus.toLowerCase() == 'requested')
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildStickyAcceptAction(data.processDetails.id ?? 0),
                ),
              if (data.processDetails.processStatus.toLowerCase() == 'in_progress')
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.08),
                          offset: const Offset(0, -8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'Add Materials',
                            Icons.add_box_rounded,
                            const Color(0xFF6366F1),
                            _showMaterialPicker,
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            'Complete',
                            Icons.check_circle_rounded,
                            const Color(0xFF10B981),
                            () => _showVerificationImagePicker(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _detailFuture?.data.processDetails.processStatus.toLowerCase() == 'completed'
          ? null
          : Padding(
              padding: EdgeInsets.only(
                bottom: _detailFuture?.data.processDetails.processStatus.toLowerCase() == 'in_progress' ? 80 : 0,
              ),
              child: FloatingActionButton(
                onPressed: () => _showPauseResumeDialog(),
                backgroundColor: _isPaused ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                elevation: 4,
                child: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 32),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Color(0xFF1E293B),
          letterSpacing: -0.5,
        ),
      ),
    );
  }
  Widget _buildStickyAcceptAction(int processId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            offset: const Offset(0, -8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            final result = await ConfirmationDialog.show(
              context: context,
              title: 'Accept Process',
              message: 'Review all details and accept this process order?',
              confirmText: 'Accept',
            );
            if (result == true) {
              try {
                await Services().acceptProcessOrder(processId);
                if (mounted) {
                  context.showSnackBar('Process accepted successfully', backgroundColor: const Color(0xFF10B981));
                  _loadDetails();
                }
              } catch (e) {
                if (mounted) {
                  context.showSnackBar('Error: $e', backgroundColor: const Color(0xFFEF4444));
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Text(
                'Accept Process Order',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap, {bool isOutlined = false}) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.white : color,
        borderRadius: BorderRadius.circular(16),
        border: isOutlined ? Border.all(color: const Color(0xFFE2E8F0), width: 1.5) : null,
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isOutlined ? const Color(0xFF64748B) : Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isOutlined ? const Color(0xFF1E293B) : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseResumeDialog() async {
    final result = await ConfirmationDialog.show(
      context: context,
      title: _isPaused ? 'Resume Process' : 'Pause Process',
      message: _isPaused ? 'Are you sure you want to resume the process?' : 'Are you sure you want to pause the process?',
      confirmText: _isPaused ? 'Resume' : 'Pause',
    );

    if (result == true) {
      if (_isPaused) {
        try {
          await Services().resumeProcess(_orderId);
          context.showSnackBar('Process resumed successfully', backgroundColor: const Color(0xFF10B981));
          _loadDetails();
        } catch (e) {
          context.showSnackBar('Failed to resume: $e', backgroundColor: const Color(0xFFEF4444));
        }
      } else {
        try {
          await Services().pauseProcess(_orderId);
          context.showSnackBar('Process paused successfully', backgroundColor: const Color(0xFF10B981));
          _loadDetails();
        } catch (e) {
          context.showSnackBar('Failed to pause: $e', backgroundColor: const Color(0xFFEF4444));
        }
      }
    }
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

  Widget _buildProductDetailsCard(ProcessOrderData order) {
    return _buildAnimatedCard(
      title: 'Product Information',
      icon: Icons.inventory_2_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.productName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                ),
              ),
              _buildStatusBadge(
                order.overDue ? 'OVERDUE' : 'ON TIME',
                order.overDue ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Description', order.productDescription, Icons.description_outlined),
          _buildDetailRow('Finish', order.finish, Icons.brush_outlined),
          _buildDetailRow('Event', order.event, Icons.event_available_outlined),
          _buildDetailRow('Dimensions', '${order.productLength} x ${order.productWidth} x ${order.productHeight}', Icons.straighten_rounded),
          if (order.estimatedDeliveryDate != null)
            _buildDetailRow(
              'Estimated Delivery',
              DateFormat('dd MMM yyyy').format(order.estimatedDeliveryDate!),
              Icons.calendar_month_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildProcessDetailsCard(ProcessDetails details, String processName) {
    return _buildAnimatedCard(
      title: 'Current Process',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Process Type', processName, Icons.category_outlined),
          _buildDetailRow('Current Status', details.processStatus.toUpperCase(), Icons.info_outline_rounded),
          if (details.expectedCompletionDate != null)
            _buildDetailRow(
              'Expected Completion',
              DateFormat('dd MMM yyyy').format(details.expectedCompletionDate!),
              Icons.timer_outlined,
            ),
          if (details.completionDate != null)
            _buildDetailRow(
              'Actual Completion',
              DateFormat('dd MMM yyyy').format(details.completionDate!),
              Icons.done_all_rounded,
            ),
          if (details.images.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Verification Images',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            _buildImageCarousel(details.images),
          ],
        ],
      ),
    );
  }

  Widget _buildManagerDetailsCard(User mainManager, User processManager) {
    return _buildAnimatedCard(
      title: 'Assigned Managers',
      icon: Icons.manage_accounts_rounded,
      child: Column(
        children: [
          _buildUserTile('Main Manager', mainManager, const Color(0xFF6366F1)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildUserTile('Process Manager', processManager, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildWorkersDetailsCard(List<User> workers) {
    return _buildAnimatedCard(
      title: 'Worker Team',
      icon: Icons.groups_rounded,
      child: workers.isEmpty
          ? const Center(child: Text('No workers assigned', style: TextStyle(color: Color(0xFF94A3B8))))
          : Column(
              children: workers.asMap().entries.map((entry) {
                return Column(
                  children: [
                    _buildUserTile('Worker ${entry.key + 1}', entry.value, const Color(0xFF64748B)),
                    if (entry.key < workers.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildUsedMaterialsCard(List<UsedMaterial> materials) {
    return _buildAnimatedCard(
      title: 'Materials Inventory',
      icon: Icons.inventory_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Used Materials',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
              ),
              if (materials.isNotEmpty)
                Text(
                  'Total: ₹${materials.fold(0.0, (sum, material) => sum + (material.materialUsed.totalPrice ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF6366F1)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          materials.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No materials used yet', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                  ),
                )
              : Column(
                  children: materials.map((m) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.architecture_rounded, size: 18, color: Color(0xFF6366F1)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.material.name,
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 14),
                                    ),
                                    _buildStatusBadge(m.material.stockAvailability.toUpperCase(), const Color(0xFF6366F1)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  bool? res = await ConfirmationDialog.show(
                                    title: 'Delete Material',
                                    message: 'Are you sure you want to delete this material?',
                                    context: context,
                                  );
                                  if (res == true) {
                                    await Services().deleteProcessMaterial(
                                      processDetailsId: widget.processDetailsId,
                                      materialId: m.material.id,
                                    );
                                    if (context.mounted) {
                                      context.showSnackBar('Material deleted successfully', backgroundColor: const Color(0xFF10B981));
                                      _loadDetails();
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMiniDetail('Qty', m.materialUsed.quantity.toString()),
                              _buildMiniDetail('Price', '₹${m.materialUsed.materialPrice}'),
                              _buildMiniDetail('Total', '₹${m.materialUsed.totalPrice}', isBold: true),
                            ],
                          ),
                          if (m.material.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              m.material.description,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildMiniDetail(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? const Color(0xFF1E293B) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard({required String title, required IconData icon, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.3),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    if (value.isEmpty || value.contains('null')) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(String label, User user, Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Icon(Icons.person_rounded, color: color, size: 22)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
              Text(user.name ?? 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              if (user.phone != null)
                Text(user.phone!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
    );
  }
}
