import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/enquiry_creation_data.dart';
import 'package:madeira/app/models/manager_order_detail_model.dart';
import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/models/material_model.dart';
import 'package:madeira/app/models/process_model.dart';
import 'package:madeira/app/models/user_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:madeira/app/widgets/audio_player.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/downloadable_media_section.dart';
import 'package:madeira/app/widgets/searchable_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class ManagerOrderDetailPage extends StatefulWidget {
  final int orderId;

  const ManagerOrderDetailPage({super.key, required this.orderId});

  @override
  State<ManagerOrderDetailPage> createState() => _ManagerOrderDetailPageState();
}

class _ManagerOrderDetailPageState extends State<ManagerOrderDetailPage> {
  late Future<ManagerOrderDetail> _orderDetailFuture;
  late EnquiryCreationData _creationData;
  ManagerOrderDetail? orderDetail;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _orderDetailFuture = Services().getManagerOrderDetail(widget.orderId);
    _loadCreationData();
    _orderDetailFuture.then((value) => orderDetail = value);
  }

  Future<void> _loadCreationData() async {
    final response = await Services().getEnquiryCreationData();
    setState(() {
      _creationData = EnquiryCreationData.fromJson(response);
    });
  }

  Future<void> _showChangeProcessBottomSheet() async {
    User? selectedManager;
    List<User>? selectedWorkers;
    DateTime? selectedDate;
    Process? selectedProcess;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Process',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSelectionTile(
                            label: 'Select Process',
                            value: selectedProcess?.name ?? 'Choose a process',
                            icon: Icons.auto_awesome_rounded,
                            isSelected: selectedProcess != null,
                            onTap: () async {
                              final result = await showModalBottomSheet<Process>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => SearchablePicker<Process>(
                                  title: 'Select Process',
                                  items: _creationData.processes,
                                  getLabel: (process) => process.name ?? '',
                                  getSubtitle: (process) => process.description ?? '',
                                ),
                              );
                              if (result != null) {
                                setState(() => selectedProcess = result);
                              }
                            },
                          ),
                          _buildSelectionTile(
                            label: 'Process Manager',
                            value: selectedManager?.name ?? 'Select a manager',
                            icon: Icons.person_rounded,
                            isSelected: selectedManager != null,
                            onTap: () async {
                              final result = await showModalBottomSheet<User>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => SearchablePicker<User>(
                                  title: 'Select Manager',
                                  items: _creationData.managers,
                                  getLabel: (user) => user.name ?? 'No Name',
                                  getSubtitle: (user) => user.phone ?? 'No Phone',
                                ),
                              );
                              if (result != null) {
                                setState(() => selectedManager = result);
                              }
                            },
                          ),
                          _buildSelectionTile(
                            label: 'Process Workers',
                            value: selectedWorkers?.map((e) => e.name).join(', ') ?? 'Choose workers',
                            icon: Icons.group_rounded,
                            isSelected: selectedWorkers?.isNotEmpty ?? false,
                            onTap: () async {
                              final result = await showModalBottomSheet<List<User>>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => SearchablePicker<User>(
                                  title: 'Select Workers',
                                  items: _creationData.managers,
                                  getLabel: (user) => user.name ?? 'No Name',
                                  getSubtitle: (user) => user.phone ?? 'No Phone',
                                  allowMultiple: true,
                                  selectedItems: selectedWorkers,
                                ),
                              );
                              if (result != null) {
                                setState(() => selectedWorkers = result);
                              }
                            },
                          ),
                          _buildSelectionTile(
                            label: 'Completion Date',
                            value: selectedDate != null
                                ? DateFormat('dd MMM yyyy').format(selectedDate!)
                                : 'Select expected date',
                            icon: Icons.calendar_today_rounded,
                            isSelected: selectedDate != null,
                            onTap: () async {
                              final result = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF6366F1),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF1E293B),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (result != null) {
                                setState(() => selectedDate = result);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: selectedProcess != null &&
                              selectedManager != null &&
                              selectedWorkers?.isNotEmpty == true &&
                              selectedDate != null
                          ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                          : null,
                      color: selectedProcess == null ||
                              selectedManager == null ||
                              selectedWorkers?.isEmpty == true ||
                              selectedDate == null
                          ? const Color(0xFFE2E8F0)
                          : null,
                      boxShadow: selectedProcess != null &&
                              selectedManager != null &&
                              selectedWorkers?.isNotEmpty == true &&
                              selectedDate != null
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: ElevatedButton(
                      onPressed: selectedProcess != null &&
                              selectedManager != null &&
                              selectedWorkers?.isNotEmpty == true &&
                              selectedDate != null
                          ? () => Navigator.pop(context, true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        'Add Process',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    bool endResult = false;
    if (result == true) {
      endResult = await ConfirmationDialog.show(
            title: 'Confirmation',
            message: 'Are you sure you want to add this process?',
            context: context,
          ) ??
          false;
    }
    if (endResult && orderDetail != null) {
      try {
        await Services().addToProcess(
          orderId: widget.orderId,
          processId: selectedProcess!.id ?? 0,
          processManagerId: selectedManager!.id!,
          processWorkersId: selectedWorkers!.map((e) => e.id!).toList(),
          expectedCompletionDate:
              DateFormat('yyyy-MM-dd').format(selectedDate!),
        );
        setState(() {
          _orderDetailFuture = Services().getManagerOrderDetail(widget.orderId);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ManagerOrderDetail>(
      future: _orderDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CupertinoActivityIndicator(radius: 16)),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('No data available')),
          );
        }

        final orderData = snapshot.data!.orderData;
        final orderDetail = snapshot.data!;
        final images = orderData.images ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 110.0,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF6366F1),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    orderData.productName ?? 'Order Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var audio in orderData.audio ?? [])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: AudioPlayer(audioUrl: audio.audio.toString().toUrl),
                        ),
                      _buildProductDetails(orderData),
                      if (images.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        DownloadableMediaSection(
                          imageUrls: images.map((img) => img.image.toImageUrl).toList(),
                          title: 'Product Media',
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildCustomerDetails(orderData),
                      const SizedBox(height: 24),
                      _buildManagerDetails(orderDetail.mainManager),
                      const SizedBox(height: 24),
                      _buildMaterialsList(orderDetail.materials),
                      const SizedBox(height: 24),
                      _buildCarpenterDetails(orderDetail.carpenterEnquiryData),
                      const SizedBox(height: 24),
                      _buildCompletedProcesses(orderDetail.completedProcessData),
                      if (orderDetail.currentProcess != null) ...[
                        const SizedBox(height: 24),
                        _buildCurrentProcess(orderDetail.currentProcess!),
                      ],
                      const SizedBox(height: 32),
                      if (orderData.status != 'completed' && !isCompleted) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                label: 'Add Process',
                                color: const Color(0xFF6366F1),
                                onPressed: _showChangeProcessBottomSheet,
                                icon: Icons.add_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                label: 'Complete Order',
                                color: const Color(0xFF10B981),
                                onPressed: () async {
                                  bool? res = await ConfirmationDialog.show(
                                    title: 'Confirmation',
                                    message: 'Are you sure you want to complete the order?',
                                    context: context,
                                  );
                                  if (res == true) {
                                    await Services().finishOrder(widget.orderId);
                                    setState(() => isCompleted = true);
                                  }
                                },
                                icon: Icons.check_circle_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<EnquiryImage> images) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: images.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: images.map((image) {
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
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
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
    );
  }

  Widget _buildProductDetails(OrderData orderData) {
    return _buildAnimatedSection(
      index: 1,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Product Details', Icons.inventory_2_rounded, const Color(0xFF6366F1)),
            const SizedBox(height: 24),
            _buildDetailRow('Name', orderData.productName ?? 'N/A'),
            _buildDetailRow('Description', orderData.productDescription ?? 'N/A'),
            _buildDetailRow('Status', orderData.status?.toUpperCase() ?? 'N/A'),
            _buildDetailRow('Priority', orderData.priority?.toUpperCase() ?? 'N/A'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildVerticalDetail('Length', '${orderData.productLength} ft')),
                Expanded(child: _buildVerticalDetail('Width', '${orderData.productWidth} ft')),
                Expanded(child: _buildVerticalDetail('Height', '${orderData.productHeight} ft')),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Finish', orderData.finish ?? 'N/A'),
            _buildDetailRow('Event', orderData.event ?? 'N/A'),
            _buildDetailRow('Estimated Price', '₹${orderData.estimatedPrice ?? 'N/A'}'),
            _buildDetailRow('Material Cost', '₹${orderData.materialCost ?? 'N/A'}'),
            _buildDetailRow('Ongoing Expense', '₹${orderData.ongoingExpense ?? 'N/A'}'),
            if (orderData.estimatedDeliveryDate != null)
              _buildDetailRow('Estimated Delivery', DateFormat('dd MMM yyyy').format(orderData.estimatedDeliveryDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(OrderData orderData) {
    return _buildAnimatedSection(
      index: 2,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Customer Details', Icons.person_rounded, const Color(0xFF10B981)),
            const SizedBox(height: 24),
            _buildDetailRow('Name', orderData.customerName ?? 'N/A'),
            _buildDetailRow('Contact', orderData.contactNumber ?? 'N/A',
                onTap: orderData.contactNumber != null
                    ? () => _launchPhone(orderData.contactNumber!)
                    : null),
            _buildDetailRow('WhatsApp', orderData.whatsappNumber ?? 'N/A',
                onTap: orderData.whatsappNumber != null
                    ? () => _launchPhone(orderData.whatsappNumber!)
                    : null),
            _buildDetailRow('Email', orderData.email ?? 'N/A'),
            _buildDetailRow('Address', orderData.address ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerDetails(User manager) {
    return _buildAnimatedSection(
      index: 3,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Main Manager', Icons.manage_accounts_rounded, const Color(0xFFF59E0B)),
            const SizedBox(height: 24),
            _buildDetailRow('Name', manager.name ?? 'N/A'),
            _buildDetailRow('Phone', manager.phone ?? 'N/A'),
            _buildDetailRow('Email', manager.email ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsList(List<MaterialModel> materials) {
    if (materials.isEmpty) return const SizedBox.shrink();
    return _buildAnimatedSection(
      index: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Materials', Icons.category_rounded, const Color(0xFF8B5CF6)),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final material = materials[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: const Icon(Icons.inventory_rounded, color: Color(0xFF8B5CF6), size: 18),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.name ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (material.description != null)
                              Text(
                                material.description!,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${material.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
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

  Widget _buildCarpenterDetails(CarpenterEnquiryData carpenterData) {
    return _buildAnimatedSection(
      index: 5,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Carpenter Details', Icons.construction_rounded, const Color(0xFF4F46E5)),
            const SizedBox(height: 24),
            _buildDetailRow('Name', carpenterData.carpenterUser.name ?? 'N/A'),
            _buildDetailRow('Phone', carpenterData.carpenterUser.phone ?? 'N/A'),
            _buildDetailRow('Email', carpenterData.carpenterUser.email ?? 'N/A'),
            _buildDetailRow('Status', carpenterData.carpenterData.isNotEmpty ? 'COMPLETE' : 'PENDING'),
            if (carpenterData.carpenterData.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...carpenterData.carpenterData.map((process) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Material', process.material?.name ?? 'N/A'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildVerticalDetail('Length', '${process.materialLength} ft')),
                          Expanded(child: _buildVerticalDetail('Height', '${process.materialHeight} ft')),
                          Expanded(child: _buildVerticalDetail('Width', '${process.materialWidth} ft')),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedProcesses(List<CompletedProcessData> processes) {
    if (processes.isEmpty) return const SizedBox.shrink();
    return _buildAnimatedSection(
      index: 6,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Process History', Icons.history_rounded, const Color(0xFF64748B)),
            const SizedBox(height: 24),
            ...processes.map((process) {
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          process.completedProcess.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      process.completedProcess?.description ?? 'N/A',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 20),
                    _buildDetailRow('Status', process.completedProcessDetails?.processStatus ?? 'N/A'),
                    _buildDetailRow('Workers Salary', '₹${process.completedProcessDetails?.workersSalary ?? 'N/A'}'),
                    _buildDetailRow('Material Price', '₹${process.completedProcessDetails?.materialPrice ?? 'N/A'}'),
                    _buildDetailRow('Total Price', '₹${process.completedProcessDetails?.totalPrice ?? 'N/A'}'),
                    
                    if (process.completedProcessDetails?.images?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            viewportFraction: 1,
                            enableInfiniteScroll: false,
                            autoPlay: true,
                          ),
                          items: process.completedProcessDetails!.images!.map((image) {
                            return CachedNetworkImage(
                              imageUrl: image.image.toImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => const Center(child: CupertinoActivityIndicator()),
                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error_outline, color: Color(0xFF64748B))),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    
                    if (process.materialsUsed?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      _buildSubSectionTitle('Materials Used', Icons.inventory_2_rounded, const Color(0xFF8B5CF6)),
                      const SizedBox(height: 12),
                      ...process.materialsUsed!.map((material) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withOpacity(0.02),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.materialDetails?.name ?? 'N/A',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildSmallIconText(Icons.layers_rounded, 'Qty: ${material.materialUsedInProcess?.quantity ?? 'N/A'}'),
                                  const SizedBox(width: 20),
                                  _buildSmallIconText(Icons.payments_rounded, '₹${material.materialUsedInProcess?.materialPrice ?? 'N/A'}'),
                                ],
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              Text(
                                'Total: ₹${material.materialUsedInProcess?.totalPrice ?? 'N/A'}',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    
                    if (process.workersData?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      _buildProcessWorkers(process.workersData!),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  Widget _buildSmallIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCurrentProcess(CurrentProcess process) {
    if (process.currentProcess == null) return const SizedBox.shrink();
    return _buildAnimatedSection(
      index: 7,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Current Process', Icons.pending_actions_rounded, const Color(0xFFF59E0B)),
            const SizedBox(height: 24),
            Text(
              process.currentProcess?.name ?? 'N/A',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
            Text(
              process.currentProcess?.description ?? 'N/A',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            if (process.currentProcessDetails != null) ...[
              _buildProcessDetails(process.currentProcessDetails!),
              if (process.currentProcessDetails?.images?.isNotEmpty ?? false) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      autoPlay: true,
                    ),
                    items: process.currentProcessDetails!.images!.map((image) {
                      return CachedNetworkImage(
                        imageUrl: image.image.toImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const Center(child: CupertinoActivityIndicator()),
                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error_outline, color: Color(0xFF64748B))),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
            if (process.currentProcessMaterialsUsed != null)
              _buildProcessMaterials(process.currentProcessMaterialsUsed!),
            if (process.currentProcessWorkers != null)
              _buildProcessWorkers(process.currentProcessWorkers!),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessDetails(ProcessDetails details) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubSectionTitle('Process Info', Icons.info_rounded, const Color(0xFF10B981)),
          const SizedBox(height: 20),
          _buildDetailRow('Status', details.processStatus),
          if (details.expectedCompletionDate != null)
            _buildDetailRow('Expected Completion', DateFormat('dd MMM yyyy').format(details.expectedCompletionDate!)),
          if (details.completionDate != null)
            _buildDetailRow('Completed On', DateFormat('dd MMM yyyy').format(details.completionDate!)),
          _buildDetailRow('Workers Salary', '₹${details.workersSalary}'),
          _buildDetailRow('Material Price', '₹${details.materialPrice}'),
          _buildDetailRow('Total Price', '₹${details.totalPrice}'),
          _buildDetailRow('Over Due', details.overDue ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildProcessMaterials(List<MaterialUsed> materials) {
    if (materials.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubSectionTitle('Materials Used', Icons.inventory_2_rounded, const Color(0xFF8B5CF6)),
          const SizedBox(height: 20),
          ...materials.map((material) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.02),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.materialDetails.name ?? 'N/A',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSmallIconText(Icons.layers_rounded, 'Qty: ${material.materialUsedInProcess.quantity ?? 'N/A'}'),
                      const SizedBox(width: 20),
                      _buildSmallIconText(Icons.payments_rounded, '₹${material.materialUsedInProcess.materialPrice ?? 'N/A'}'),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  Text(
                    'Total Price: ₹${material.materialUsedInProcess.totalPrice ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 14),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProcessWorkers(List<User> workers) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.group_rounded,
                  color: Color(0xFF6366F1),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Assigned Workers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...workers.map((worker) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.02),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF6366F1), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.name ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                          ),
                        ),
                        if (worker.phone != null)
                          Text(
                            worker.phone!,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVerticalDetail(String label, String value) {
    if (value == 'N/A' || value.isEmpty || value.contains('null')) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFF1F5F9),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildDetailRow(String label, String value, {VoidCallback? onTap}) {
    if (value == 'N/A' || value.isEmpty || value == 'nullxnullxnull') return const SizedBox.shrink();

    final bool isPhone = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isPhone ? const Color(0xFF667eea) : const Color(0xFF1E293B),
                  fontSize: 14,
                  height: 1.4,
                  decoration: isPhone ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
            if (isPhone)
              const Icon(Icons.call_rounded, size: 18, color: Color(0xFF667eea)),
          ],
        ),
      ),
    );
  }
}
