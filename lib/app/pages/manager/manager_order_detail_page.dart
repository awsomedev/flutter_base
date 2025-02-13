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
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/searchable_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class ManagerOrderDetailPage extends StatefulWidget {
  final int orderId;

  const ManagerOrderDetailPage({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<ManagerOrderDetailPage> createState() => _ManagerOrderDetailPageState();
}

class _ManagerOrderDetailPageState extends State<ManagerOrderDetailPage> {
  late Future<ManagerOrderDetail> _orderDetailFuture;
  late EnquiryCreationData _creationData;
  ManagerOrderDetail? orderDetail;

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
      appBar: AppBar(
        title: const Text('Order Details'),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(orderDetail.orderData.images ?? []),
                  const SizedBox(height: 20),
                  _buildProductDetails(orderDetail.orderData),
                  const SizedBox(height: 20),
                  _buildCustomerDetails(orderDetail.orderData),
                  const SizedBox(height: 20),
                  _buildManagerDetails(orderDetail.mainManager),
                  const SizedBox(height: 20),
                  _buildMaterialsList(orderDetail.materials),
                  const SizedBox(height: 20),
                  _buildCarpenterDetails(orderDetail.carpenterEnquiryData),
                  const SizedBox(height: 20),
                  _buildCompletedProcesses(orderDetail.completedProcessData),
                  if (orderDetail.currentProcess != null) ...[
                    const SizedBox(height: 20),
                    _buildCurrentProcess(orderDetail.currentProcess!),
                  ],
                  const SizedBox(height: 20),
                  if (orderDetail.orderData.status != 'completed' &&
                      !isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showChangeProcessBottomSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Add to process',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (orderDetail.orderData.status != 'completed' &&
                      !isCompleted)
                    SizedBox(
                      width: double.infinity,
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
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Complete Order',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildProductDetails(OrderData orderData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Main Manager',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Materials',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return ListTile(
                  title: Text(material.name),
                  subtitle: Text(material.description),
                  trailing: Text('₹${material.price}'),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Carpenter Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            ...carpenterData.carpenterData.map((process) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  _buildDetailRow('Material', process.material?.name ?? 'N/A'),
                  _buildDetailRow('Length', '${process.materialLength} ft'),
                  _buildDetailRow('Height', '${process.materialHeight} ft'),
                  _buildDetailRow('Width', '${process.materialWidth} ft'),
                ]),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Completed Processes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...processes.map((process) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    process.completedProcess.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Text(
                  //   process.completedProcess?.description ?? 'N/A',
                  //   style: const TextStyle(color: AppColors.textSecondary),
                  // ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   'Status: ${process.completedProcessDetails?.processStatus ?? 'N/A'}',
                  //   style: const TextStyle(color: AppColors.textSecondary),
                  // ),

                  Text(process.completedProcess?.description ?? 'N/A'),
                  const SizedBox(height: 8),
                  Text(
                      'Status: ${process.completedProcessDetails?.processStatus ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text(
                      'Workers Salary: ${process.completedProcessDetails?.workersSalary ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text(
                      'Material Price: ${process.completedProcessDetails?.materialPrice ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Total Price: ${process.completedProcessDetails?.totalPrice ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (process.completedProcessDetails?.images != null &&
                      process.completedProcessDetails!.images!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Process Images',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CarouselSlider(
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
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
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
                        const SizedBox(height: 16),
                      ],
                    ),

                  if (process.completedProcessDetails?.expectedCompletionDate !=
                      null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Expected Completion: ${DateFormat('dd MMM yyyy').format(process.completedProcessDetails!.expectedCompletionDate!)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  if (process.completedProcessDetails?.completionDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Completed On: ${DateFormat('dd MMM yyyy').format(process.completedProcessDetails!.completionDate!)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (process.materialsUsed != null) ...[
                    const Text(
                      'Materials Used',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...process.materialsUsed!.map((material) {
                      final materialDetails = material.materialDetails;
                      final materialUsedInProcess =
                          material.materialUsedInProcess;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    materialDetails?.name ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Qty: ${materialUsedInProcess?.quantity ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.currency_rupee,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      Text(
                                        '${materialUsedInProcess?.materialPrice ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Total Price: ₹${materialUsedInProcess?.totalPrice ?? 'N/A'}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  if (process.workersData != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Workers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...process.workersData!.map((worker) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    worker.name ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (worker.phone != null)
                                    Text(
                                      worker.phone!,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCurrentProcess(CurrentProcess process) {
    if (process.currentProcess == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Process',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              process.currentProcess?.name ?? 'N/A',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(process.currentProcess?.description ?? 'N/A'),
            const SizedBox(height: 10),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Process Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materials Used',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...materials.map((material) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.materialDetails.name ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Qty: ${material.materialUsedInProcess.quantity ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.currency_rupee,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            Text(
                              '${material.materialUsedInProcess.materialPrice ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Total Price: ₹${material.materialUsedInProcess.totalPrice ?? 'N/A'}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProcessWorkers(List<User> workers) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workers',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return ListTile(
                title: Text(worker.name ?? 'N/A'),
                subtitle: Text(worker.phone ?? 'N/A'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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

class DetailCard extends StatelessWidget {
  final CompletedProcessData process;
  const DetailCard({
    super.key,
    required this.process,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Materials Used',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: process.materialsUsed!.map((material) {
            final materialDetails = material.materialDetails;
            final materialUsedInProcess = material.materialUsedInProcess;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materialDetails?.name ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Qty: ${materialUsedInProcess?.quantity ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.currency_rupee,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            Text(
                              '${materialUsedInProcess?.materialPrice ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Total Price: ₹${materialUsedInProcess?.totalPrice ?? 'N/A'}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
