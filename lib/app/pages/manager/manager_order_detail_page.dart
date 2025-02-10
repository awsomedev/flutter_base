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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completed Processes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: processes.length,
              itemBuilder: (context, index) {
                final process = processes[index];
                return ExpansionTile(
                  title: Text(process.completedProcess.name),
                  subtitle: Text(process.completedProcess.description),
                  children: [
                    _buildProcessDetails(process.completedProcessDetails),
                    _buildProcessMaterials(process.materialsUsed),
                    _buildProcessWorkers(process.workersData),
                  ],
                );
              },
            ),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              return ListTile(
                title: Text(material.materialDetails.name),
                subtitle: Text(
                    'Quantity: ${material.materialUsedInProcess.quantity}'),
                trailing: Text('₹${material.materialUsedInProcess.totalPrice}'),
              );
            },
          ),
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
