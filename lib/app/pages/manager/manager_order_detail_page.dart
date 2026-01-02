import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:madeira/app/widgets/audio_player.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
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
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Process',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Process'),
                    subtitle: Text(selectedProcess?.name ?? 'Select Process'),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
                  ListTile(
                    title: const Text('Process Manager'),
                    subtitle: Text(selectedManager?.name ?? 'Select Manager'),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
                  ListTile(
                    title: const Text('Process Workers'),
                    subtitle: Text(
                        selectedWorkers?.map((e) => e.name).join(', ') ??
                            'Select Workers'),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
                  ListTile(
                    title: const Text('Expected Completion Date'),
                    subtitle: Text(selectedDate != null
                        ? DateFormat('dd MMM yyyy').format(selectedDate!)
                        : 'Select Date'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (result != null) {
                        setState(() => selectedDate = result);
                      }
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: selectedProcess != null &&
                              selectedManager != null &&
                              selectedWorkers != null &&
                              selectedWorkers!.isNotEmpty &&
                              selectedDate != null
                          ? () => Navigator.pop(context, true)
                          : null,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<ManagerOrderDetail>(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final orderDetail = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(orderDetail.orderData.images ?? []),
                const SizedBox(height: 24),
                for (var audio in orderDetail.orderData.audio ?? [])
                  AudioPlayer(audioUrl: audio.audio.toString().toUrl),
                const SizedBox(height: 24),
                _buildProductDetails(orderDetail.orderData),
                const SizedBox(height: 24),
                _buildCustomerDetails(orderDetail.orderData),
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
                const SizedBox(height: 24),
                if (orderDetail.orderData.status != 'completed' && !isCompleted)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _showChangeProcessBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add to process',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (orderDetail.orderData.status != 'completed' && !isCompleted)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        bool? res = await ConfirmationDialog.show(
                          title: 'Confirmation',
                          message:
                              'Are you sure you want to complete the order?',
                          context: context,
                        );
                        if (res == true) {
                          await Services().finishOrder(widget.orderId);
                          setState(() {
                            isCompleted = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Complete Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Name', orderData.productName ?? 'N/A'),
            _buildDetailRow(
                'Description', orderData.productDescription ?? 'N/A'),
            _buildDetailRow('Status', orderData.status ?? 'N/A'),
            _buildDetailRow('Priority', orderData.priority ?? 'N/A'),
            _buildDetailRow('Dimensions',
                '${orderData.productLength}x${orderData.productWidth}x${orderData.productHeight}'),
            _buildDetailRow('Finish', orderData.finish ?? 'N/A'),
            _buildDetailRow('Event', orderData.event ?? 'N/A'),
            _buildDetailRow(
                'Estimated Price', '₹${orderData.estimatedPrice ?? 'N/A'}'),
            _buildDetailRow(
                'Material Cost', '₹${orderData.materialCost ?? 'N/A'}'),
            _buildDetailRow(
                'Ongoing Expense', '₹${orderData.ongoingExpense ?? 'N/A'}'),
            if (orderData.estimatedDeliveryDate != null)
              _buildDetailRow(
                  'Estimated Delivery',
                  DateFormat('dd MMM yyyy')
                      .format(orderData.estimatedDeliveryDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(OrderData orderData) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Name', orderData.customerName ?? 'N/A'),
            _buildDetailRow('Contact', orderData.contactNumber ?? 'N/A'),
            _buildDetailRow('WhatsApp', orderData.whatsappNumber ?? 'N/A'),
            _buildDetailRow('Email', orderData.email ?? 'N/A'),
            _buildDetailRow('Address', orderData.address ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerDetails(User manager) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.manage_accounts,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Main Manager',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Name', manager.name ?? 'N/A'),
            _buildDetailRow('Phone', manager.phone ?? 'N/A'),
            _buildDetailRow('Email', manager.email ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList(List<MaterialModel> materials) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: Colors.purple[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Materials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.name ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (material.description != null)
                              Text(
                                material.description!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${material.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.construction,
                    color: Colors.indigo[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Carpenter Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Name', carpenterData.carpenterUser.name ?? 'N/A'),
            _buildDetailRow(
                'Phone', carpenterData.carpenterUser.phone ?? 'N/A'),
            _buildDetailRow(
                'Email', carpenterData.carpenterUser.email ?? 'N/A'),
            _buildDetailRow(
                'Status',
                carpenterData.carpenterData.isNotEmpty
                    ? 'Complete'
                    : 'Pending'),
            const SizedBox(height: 16),
            ...carpenterData.carpenterData.map((process) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Material', process.material?.name ?? 'N/A'),
                    _buildDetailRow('Length', '${process.materialLength} ft'),
                    _buildDetailRow('Height', '${process.materialHeight} ft'),
                    _buildDetailRow('Width', '${process.materialWidth} ft'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedProcesses(List<CompletedProcessData> processes) {
    if (processes.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Completed Processes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...processes.map((process) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      process.completedProcess.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(process.completedProcess?.description ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                        'Status',
                        process.completedProcessDetails?.processStatus ??
                            'N/A'),
                    _buildDetailRow('Workers Salary',
                        '₹${process.completedProcessDetails?.workersSalary ?? 'N/A'}'),
                    _buildDetailRow('Material Price',
                        '₹${process.completedProcessDetails?.materialPrice ?? 'N/A'}'),
                    _buildDetailRow('Total Price',
                        '₹${process.completedProcessDetails?.totalPrice ?? 'N/A'}'),
                    if (process.completedProcessDetails?.images != null &&
                        process
                            .completedProcessDetails!.images!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Process Images',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            viewportFraction: 1,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true,
                            autoPlay: true,
                          ),
                          items: process.completedProcessDetails!.images!
                              .map((image) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: image.image.toImageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                        child: Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    if (process
                            .completedProcessDetails?.expectedCompletionDate !=
                        null)
                      _buildDetailRow(
                          'Expected Completion',
                          DateFormat('dd MMM yyyy').format(process
                              .completedProcessDetails!
                              .expectedCompletionDate!)),
                    if (process.completedProcessDetails?.completionDate != null)
                      _buildDetailRow(
                          'Completed On',
                          DateFormat('dd MMM yyyy').format(process
                              .completedProcessDetails!.completionDate!)),
                    if (process.materialsUsed != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.category_outlined,
                              color: Colors.purple[600],
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Materials Used',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...process.materialsUsed!.map((material) {
                        final materialDetails = material.materialDetails;
                        final materialUsedInProcess =
                            material.materialUsedInProcess;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                materialDetails?.name ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                      'Qty: ${materialUsedInProcess?.quantity ?? 'N/A'}'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.currency_rupee,
                                      size: 16, color: Colors.grey),
                                  Text(
                                      '${materialUsedInProcess?.materialPrice ?? 'N/A'}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Price: ₹${materialUsedInProcess?.totalPrice ?? 'N/A'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (process.workersData != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.blue[600],
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Workers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...process.workersData!.map((worker) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      worker.name ?? 'N/A',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    if (worker.phone != null)
                                      Text(
                                        worker.phone!,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

  Widget _buildCurrentProcess(CurrentProcess process) {
    if (process.currentProcess == null) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pending_actions,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Current Process',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              process.currentProcess?.name ?? 'N/A',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(process.currentProcess?.description ?? 'N/A'),
            const SizedBox(height: 16),
            if (process.currentProcessDetails != null)
              _buildProcessDetails(process.currentProcessDetails!),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.green[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Process Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Status', details.processStatus),
          if (details.expectedCompletionDate != null)
            _buildDetailRow(
                'Expected Completion',
                DateFormat('dd MMM yyyy')
                    .format(details.expectedCompletionDate!)),
          if (details.completionDate != null)
            _buildDetailRow('Completed On',
                DateFormat('dd MMM yyyy').format(details.completionDate!)),
          _buildDetailRow('Workers Salary', '₹${details.workersSalary}'),
          _buildDetailRow('Material Price', '₹${details.materialPrice}'),
          _buildDetailRow('Total Price', '₹${details.totalPrice}'),
          _buildDetailRow('Over Due', details.overDue ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildProcessMaterials(List<MaterialUsed> materials) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: Colors.purple[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Materials Used',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...materials.map((material) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.materialDetails.name ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                          'Qty: ${material.materialUsedInProcess.quantity ?? 'N/A'}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.currency_rupee,
                          size: 16, color: Colors.grey),
                      Text(
                          '${material.materialUsedInProcess.materialPrice ?? 'N/A'}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Price: ₹${material.materialUsedInProcess.totalPrice ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.group,
                  color: Colors.blue[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Workers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...workers.map((worker) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.name ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (worker.phone != null)
                          Text(
                            worker.phone!,
                            style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
