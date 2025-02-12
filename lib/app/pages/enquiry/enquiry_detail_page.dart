import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/manager_order_detail_model.dart';
import 'package:madeira/app/widgets/progress_indicator_widget.dart';

import '../../models/enquiry_detail_response_model.dart' as detail_model;
import '../../app_essentials/colors.dart';
import '../../services/services.dart';
import '../../extensions/context_extensions.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/process_detail_model.dart';

class EnquiryDetailPage extends StatefulWidget {
  final int enquiryId;

  const EnquiryDetailPage({
    Key? key,
    required this.enquiryId,
  }) : super(key: key);

  @override
  State<EnquiryDetailPage> createState() => _EnquiryDetailPageState();
}

class _EnquiryDetailPageState extends State<EnquiryDetailPage> {
  bool _isCarpenterRequested = false;

  Future<void> _requestCarpenter(BuildContext context) async {
    try {
      await Services().requestCarpenter(widget.enquiryId);

      if (context.mounted) {
        setState(() {
          _isCarpenterRequested = true;
        });
        context.showSnackBar(
          'Carpenter requested successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar(
          'Failed to request carpenter: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 24),
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
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(detail_model.EnquiryDetailResponse enquiryDetail) {
    final images = enquiryDetail.product?.materialImages;
    if (images == null || images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 250,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            autoPlay: false,
          ),
          items: images.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMaterialsList(detail_model.EnquiryDetailResponse enquiryDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Materials',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enquiryDetail.materials?.length ?? 0,
          itemBuilder: (context, index) {
            final material = enquiryDetail.materials?[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material?.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(material?.description ?? 'N/A'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantity: ${material?.quantity}'),
                        Text('Price: ₹${material?.price}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTeamSection(detail_model.EnquiryDetailResponse enquiryDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Main Manager',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Name', enquiryDetail.mainManager?.name ?? 'N/A'),
                _buildDetailRow(
                    'Email', enquiryDetail.mainManager?.email ?? 'N/A'),
                _buildDetailRow(
                    'Phone', enquiryDetail.mainManager?.phone ?? 'N/A'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (enquiryDetail.carpenterEnquiryData?.carpenterUser != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carpenter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Name',
                    enquiryDetail.carpenterEnquiryData?.carpenterUser?.name ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Email',
                    enquiryDetail.carpenterEnquiryData?.carpenterUser?.email ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Phone',
                    enquiryDetail.carpenterEnquiryData?.carpenterUser?.phone ??
                        'N/A',
                  ),
                  if (enquiryDetail.carpenterEnquiryData?.carpenterData !=
                          null &&
                      enquiryDetail.carpenterEnquiryData?.carpenterData
                              ?.isNotEmpty ==
                          true)
                    _buildDetailRow(
                      'Status',
                      enquiryDetail.carpenterEnquiryData?.carpenterData?.first
                              .status ??
                          'N/A',
                    ),
                ],
              ),
            ),
          ),
        if (enquiryDetail.carpenterEnquiryData?.carpenterData != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                enquiryDetail.carpenterEnquiryData!.carpenterData!.map((data) {
              return Card(
                margin: const EdgeInsets.only(top: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          'Material Name', data.material?.name ?? 'N/A'),
                      _buildDetailRow('Material Name(Mal)',
                          data.material?.nameMal ?? 'N/A'),
                      // _buildDetailRow(
                      //     'Material ID', '${data.materialId ?? 'N/A'}'),
                      _buildDetailRow(
                          'Material Length', '${data.materialLength ?? 'N/A'}'),
                      _buildDetailRow(
                          'Material Height', '${data.materialHeight ?? 'N/A'}'),
                      _buildDetailRow(
                          'Material Width', '${data.materialWidth ?? 'N/A'}'),
                      // _buildDetailRow('Status', data.status ?? 'N/A'),
                      // _buildDetailRow(
                      //     'Carpenter ID', '${data.carpenterId ?? 'N/A'}'),
                      _buildDetailRow(
                          'Material Cost', '₹${data.material?.price ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildCompletedProcesses(
      List<detail_model.CompletedProcessData>? completedProcesses) {
    if (completedProcesses == null || completedProcesses.isEmpty) {
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
        ...completedProcesses.map((process) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    process.completedProcess?.name ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  if (process.materialsUsed != null)
                    DetailCard(
                      process: process,
                    ),
                  if (process.workersData != null)
                    WorkerList(
                      workerData: process.workersData!,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCurrentProcess(detail_model.CurrentProcess? currentProcess) {
    if (currentProcess == null || currentProcess.currentProcess == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Process',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentProcess.currentProcess?.name ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(currentProcess.currentProcess?.description ?? 'N/A'),
                const SizedBox(height: 8),
                Text(
                    'Status: ${currentProcess.currentProcessDetails?.processStatus ?? 'N/A'}'),
                const SizedBox(height: 8),
                if (currentProcess.currentProcessMaterialsUsed != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: currentProcess.currentProcessMaterialsUsed!
                        .map((material) {
                      final materialDetails = material.currentMaterialDetails;
                      final materialUsedInProcess =
                          material.currentMaterialUsedInProcess;
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
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, detail_model.EnquiryDetailResponse enquiryDetail) {
    final orderData = enquiryDetail.orderData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(enquiryDetail),
          _buildSection(
            title: 'Product Details',
            children: [
              _buildDetailRow(
                  'Name', enquiryDetail.orderData?.productName ?? 'N/A'),
              _buildDetailRow('Description',
                  enquiryDetail.orderData?.productDescription ?? 'N/A'),
              _buildDetailRow('Name (Malayalam)',
                  enquiryDetail.orderData?.productNameMal ?? 'N/A'),
              _buildDetailRow('Description (Malayalam)',
                  enquiryDetail.orderData?.productDescriptionMal ?? 'N/A'),
              _buildDetailRow('Dimensions',
                  '${enquiryDetail.orderData?.productLength ?? 'N/A'} x ${enquiryDetail.orderData?.productWidth ?? 'N/A'} x ${enquiryDetail.orderData?.productHeight ?? 'N/A'}'),
              _buildDetailRow(
                  'Finish', enquiryDetail.orderData?.finish ?? 'N/A'),
              _buildDetailRow('Event', enquiryDetail.orderData?.event ?? 'N/A'),
              _buildDetailRow('Price',
                  '₹${enquiryDetail.orderData?.estimatedPrice ?? 'N/A'}'),
              ProgressIndicatorWidget(
                totalSteps: 100,
                currentStep: (enquiryDetail.completionPercentage ?? 0).toInt(),
                height: 10,
              ),
            ],
          ),
          _buildSection(
            title: 'Customer Information',
            children: [
              _buildDetailRow('Name', orderData?.customerName ?? 'N/A'),
              _buildDetailRow('Phone', orderData?.contactNumber ?? 'N/A'),
              _buildDetailRow('WhatsApp', orderData?.whatsappNumber ?? 'N/A'),
              _buildDetailRow('Email', orderData?.email ?? 'N/A'),
              _buildDetailRow('Address', orderData?.address ?? 'N/A'),
            ],
          ),
          _buildSection(
            title: 'Order Status',
            children: [
              _buildDetailRow(
                  'Priority', orderData?.priority?.toUpperCase() ?? 'N/A'),
              _buildDetailRow('Status', orderData?.status ?? 'N/A'),
              _buildDetailRow(
                  'Enquiry Status', orderData?.enquiryStatus ?? 'N/A'),
              _buildDetailRow('Completion',
                  '${((enquiryDetail.completionPercentage ?? 0)).toStringAsFixed(1)}%'),
              _buildDetailRow(
                  'Estimated Delivery',
                  orderData?.estimatedDeliveryDate
                          ?.toLocal()
                          .toString()
                          .split(' ')[0] ??
                      'N/A'),
              if (orderData?.estimatedPrice != null)
                _buildDetailRow(
                    'Estimated Price', '₹${orderData?.estimatedPrice}'),
              _buildDetailRow(
                  'Material Cost', '₹${orderData?.materialCost ?? 0}'),
              _buildDetailRow(
                  'Ongoing Expense', '₹${orderData?.ongoingExpense ?? 0}'),
              _buildDetailRow(
                  'Over Due', orderData?.overDue == true ? 'Yes' : 'No'),
            ],
          ),
          _buildMaterialsList(enquiryDetail),
          const SizedBox(height: 24),
          _buildTeamSection(enquiryDetail),
          const SizedBox(height: 24),
          _buildCompletedProcesses(enquiryDetail.completedProcessData),
          _buildCurrentProcess(enquiryDetail.currentProcess),
          const SizedBox(height: 24),
          if (enquiryDetail.orderData?.enquiryStatus?.toLowerCase() ==
                  'initiated' &&
              !_isCarpenterRequested)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _requestCarpenter(context),
                icon: const Icon(Icons.build),
                label: const Text(
                  'Send to Carpenter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<detail_model.EnquiryDetailResponse>(
        future: Services().getEnquiryDetails(widget.enquiryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final enquiryDetail = snapshot.data!;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                enquiryDetail.orderData?.productName ?? 'Enquiry Details',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.surface,
            ),
            body: _buildContent(context, enquiryDetail),
          );
        },
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final detail_model.CompletedProcessData process;
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

class WorkerList extends StatelessWidget {
  final List<detail_model.User> workerData;
  const WorkerList({
    super.key,
    required this.workerData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workers',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: workerData.map((worker) {
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
                          worker.name ?? 'N/A',
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
                              Icons.currency_rupee,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Salary: ${worker.salaryPerHr ?? 'N/A'}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            Text(
                              '${worker.phone}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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
