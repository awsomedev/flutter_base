import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/enquiry_detail_response_model.dart';
import 'package:madeira/app/models/manager_order_detail_model.dart';
import 'package:madeira/app/pages/enquiry/create_enquiry_page.dart';
import 'package:madeira/app/widgets/audio_player.dart';
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
          log('${enquiryDetail}');
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                enquiryDetail.orderData?.productName ?? 'Enquiry Details',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.surface,
            ),
            body: Stack(
              children: [
                EnquiryDetailContent(
                  enquiryDetail: enquiryDetail,
                  isCarpenterRequested: _isCarpenterRequested,
                  onCarpenterRequested: (value) {
                    setState(() {
                      _isCarpenterRequested = value;
                    });
                  },
                ),
                if (enquiryDetail.orderData?.overDue == true)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const Text(
                        'Over Due',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EnquiryDetailContent extends StatelessWidget {
  final detail_model.EnquiryDetailResponse enquiryDetail;
  final bool isCarpenterRequested;
  final Function(bool) onCarpenterRequested;

  const EnquiryDetailContent({
    Key? key,
    required this.enquiryDetail,
    required this.isCarpenterRequested,
    required this.onCarpenterRequested,
  }) : super(key: key);

  Future<void> _requestCarpenter(BuildContext context) async {
    try {
      await Services().requestCarpenter(enquiryDetail.orderData?.id ?? 0);

      if (context.mounted) {
        onCarpenterRequested(true);
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

  @override
  Widget build(BuildContext context) {
    final orderData = enquiryDetail.orderData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageCarousel(
            images: enquiryDetail.product?.materialImages ??
                enquiryDetail.orderData?.images ??
                [],
          ),
          Column(
            children: [
              for (ServerAudio audio in enquiryDetail.orderData?.audio ?? [])
                AudioPlayer(audioUrl: audio.audio.toString().toUrl ?? ''),
            ],
          ),
          const SizedBox(height: 24),
          Section(
            title: 'Product Details',
            children: [
              DetailRow(
                  label: 'Name',
                  value: enquiryDetail.orderData?.productName ?? 'N/A'),
              DetailRow(
                  label: 'Description',
                  value: enquiryDetail.orderData?.productDescription ?? 'N/A'),
              DetailRow(
                  label: 'Name (Malayalam)',
                  value: enquiryDetail.orderData?.productNameMal ?? 'N/A'),
              DetailRow(
                  label: 'Description (Malayalam)',
                  value:
                      enquiryDetail.orderData?.productDescriptionMal ?? 'N/A'),
              DetailRow(
                label: 'Dimensions',
                value:
                    '${enquiryDetail.orderData?.productLength ?? 'N/A'} x ${enquiryDetail.orderData?.productWidth ?? 'N/A'} x ${enquiryDetail.orderData?.productHeight ?? 'N/A'}',
              ),
              DetailRow(
                  label: 'Finish',
                  value: enquiryDetail.orderData?.finish ?? 'N/A'),
              DetailRow(
                  label: 'Event',
                  value: enquiryDetail.orderData?.event ?? 'N/A'),
              DetailRow(
                  label: 'Price',
                  value:
                      '₹${enquiryDetail.orderData?.estimatedPrice ?? 'N/A'}'),
              ProgressIndicatorWidget(
                totalSteps: 100,
                currentStep: (enquiryDetail.completionPercentage ?? 0).toInt(),
                height: 10,
              ),
            ],
          ),
          Section(
            title: 'Customer Information',
            children: [
              DetailRow(label: 'Name', value: orderData?.customerName ?? 'N/A'),
              DetailRow(
                  label: 'Phone', value: orderData?.contactNumber ?? 'N/A'),
              DetailRow(
                  label: 'WhatsApp', value: orderData?.whatsappNumber ?? 'N/A'),
              DetailRow(label: 'Email', value: orderData?.email ?? 'N/A'),
              DetailRow(label: 'Address', value: orderData?.address ?? 'N/A'),
            ],
          ),
          Section(
            title: 'Order Status',
            children: [
              DetailRow(
                  label: 'Priority',
                  value: orderData?.priority?.toUpperCase() ?? 'N/A'),
              DetailRow(label: 'Status', value: orderData?.status ?? 'N/A'),
              DetailRow(
                  label: 'Enquiry Status',
                  value: orderData?.enquiryStatus ?? 'N/A'),
              DetailRow(
                  label: 'Completion',
                  value:
                      '${((enquiryDetail.completionPercentage ?? 0)).toStringAsFixed(1)}%'),
              DetailRow(
                label: 'Estimated Delivery',
                value: orderData?.estimatedDeliveryDate
                        ?.toLocal()
                        .toString()
                        .split(' ')[0] ??
                    'N/A',
              ),
              DetailRow(
                  label: 'Material Cost',
                  value: '₹${orderData?.materialCost ?? 0}'),
              DetailRow(
                  label: 'Over Due',
                  value: orderData?.overDue == true ? 'Yes' : 'No'),
              if (orderData?.estimatedPrice != null)
                DetailRow(
                    label: 'Estimated Price',
                    value: '₹${orderData?.estimatedPrice}'),
              DetailRow(
                  label: 'Ongoing Expense',
                  value: '₹${orderData?.ongoingExpense ?? 0}'),
            ],
          ),
          MaterialsList(materials: enquiryDetail.materials ?? []),
          const SizedBox(height: 24),
          CustomEnquiries(enquiryDetail: enquiryDetail),
          const SizedBox(height: 24),
          TeamSection(enquiryDetail: enquiryDetail),
          const SizedBox(height: 24),
          CompletedProcessesSection(
              completedProcesses: enquiryDetail.completedProcessData),
          CurrentProcessSection(currentProcess: enquiryDetail.currentProcess),
          const SizedBox(height: 24),
          if (enquiryDetail.orderData?.enquiryStatus?.toLowerCase() ==
                  'initiated' &&
              !isCarpenterRequested)
            RequestCarpenterButton(
              onPressed: () => _requestCarpenter(context),
            ),
          const SizedBox(height: 10),
          if (enquiryDetail.orderData?.enquiryStatus?.toLowerCase() ==
                  'initiated' &&
              !isCarpenterRequested)
            EditEnquiryButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEnquiryPage(
                      orderData: enquiryDetail.orderData,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class CustomEnquiries extends StatelessWidget {
  const CustomEnquiries({
    super.key,
    required this.enquiryDetail,
  });

  final EnquiryDetailResponse enquiryDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Enquiries',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailRow(
                          label: 'Name',
                          value: enquiryDetail.enquiryList![index].userName ??
                              'N/A',
                        ),
                        DetailRow(
                          label: 'Phone',
                          value:
                              enquiryDetail.enquiryList![index].phone ?? 'N/A',
                        ),
                        DetailRow(
                          label: 'Status',
                          value: enquiryDetail.enquiryList![index].status
                              .toUpperCase(),
                        ),
                        DetailRow(
                          label: 'About Enquiry',
                          value: enquiryDetail.enquiryList![index].aboutEnquiry,
                        ),
                        DetailRow(
                          label: 'Description',
                          value: enquiryDetail
                                  .enquiryList![index].enquiryDescription ??
                              'N/A',
                        ),
                        DetailRow(
                          label: 'Cost',
                          value:
                              enquiryDetail.enquiryList![index].cost ?? 'N/A',
                        ),
                        DetailRow(
                          label: 'Days Required',
                          value: enquiryDetail
                                      .enquiryList![index].completionTime !=
                                  null
                              ? enquiryDetail.enquiryList![index].completionTime
                                  .toString()
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
            separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
            itemCount: enquiryDetail.enquiryList!.length),
      ],
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const Section({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class ImageCarousel extends StatelessWidget {
  final List<dynamic> images;

  const ImageCarousel({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
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
                      imageUrl: image.image?.toString().toUrl ?? '',
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
}

class MaterialsList extends StatelessWidget {
  final List<dynamic> materials;

  const MaterialsList({
    Key? key,
    required this.materials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
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
}

class TeamSection extends StatelessWidget {
  final detail_model.EnquiryDetailResponse enquiryDetail;

  const TeamSection({
    Key? key,
    required this.enquiryDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                DetailRow(
                    label: 'Name',
                    value: enquiryDetail.mainManager?.name ?? 'N/A'),
                DetailRow(
                    label: 'Email',
                    value: enquiryDetail.mainManager?.email ?? 'N/A'),
                DetailRow(
                    label: 'Phone',
                    value: enquiryDetail.mainManager?.phone ?? 'N/A'),
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
                  DetailRow(
                    label: 'Name',
                    value: enquiryDetail
                            .carpenterEnquiryData?.carpenterUser?.name ??
                        'N/A',
                  ),
                  DetailRow(
                    label: 'Email',
                    value: enquiryDetail
                            .carpenterEnquiryData?.carpenterUser?.email ??
                        'N/A',
                  ),
                  DetailRow(
                    label: 'Phone',
                    value: enquiryDetail
                            .carpenterEnquiryData?.carpenterUser?.phone ??
                        'N/A',
                  ),
                  if (enquiryDetail.carpenterEnquiryData?.carpenterData !=
                          null &&
                      enquiryDetail.carpenterEnquiryData?.carpenterData
                              ?.isNotEmpty ==
                          true)
                    DetailRow(
                      label: 'Status',
                      value: enquiryDetail.carpenterEnquiryData?.carpenterData
                              ?.first.status ??
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
                      DetailRow(
                          label: 'Material Name',
                          value: data.material?.name ?? 'N/A'),
                      DetailRow(
                          label: 'Material Name(Mal)',
                          value: data.material?.nameMal ?? 'N/A'),
                      if (data.type != null)
                        DetailRow(
                            label: 'Material Type',
                            value:
                                '${data.type?.replaceAll('_', ' ').capitalize}'),
                      if (data.materialLength != null &&
                          data.materialLength! > 0)
                        DetailRow(
                            label: 'Material Length',
                            value: '${data.materialLength}'),
                      if (data.materialHeight != null &&
                          data.materialHeight! > 0)
                        DetailRow(
                            label: 'Material Height',
                            value: '${data.materialHeight}'),
                      if (data.materialGirth != null && data.materialGirth! > 0)
                        DetailRow(
                            label: 'Material Girth',
                            value: '${data.materialGirth}'),
                      if (data.materialWidth != null && data.materialWidth! > 0)
                        DetailRow(
                            label: 'Material Width',
                            value: '${data.materialWidth}'),
                      if (data.materialThickness != null &&
                          data.materialThickness! > 0)
                        DetailRow(
                            label: 'Material Thickness',
                            value: '${data.materialThickness}'),
                      if (data.noOfPieces != null && data.noOfPieces! > 0)
                        DetailRow(
                            label: 'No of Pieces', value: '${data.noOfPieces}'),
                      if (data.materialCost != null)
                        DetailRow(
                            label: 'Material Cost',
                            value: '₹${data.materialCost}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class CompletedProcessesSection extends StatelessWidget {
  final List<detail_model.CompletedProcessData>? completedProcesses;

  const CompletedProcessesSection({
    Key? key,
    required this.completedProcesses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (completedProcesses == null || completedProcesses!.isEmpty) {
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
        ...completedProcesses!.map((process) {
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
                    DetailCard(process: process),
                  if (process.workersData != null)
                    WorkerList(workerData: process.workersData!),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class CurrentProcessSection extends StatelessWidget {
  final detail_model.CurrentProcess? currentProcess;

  const CurrentProcessSection({
    Key? key,
    required this.currentProcess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentProcess == null || currentProcess!.currentProcess == null) {
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
                  currentProcess!.currentProcess?.name ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(currentProcess!.currentProcess?.description ?? 'N/A'),
                const SizedBox(height: 8),
                Text(
                  'Status: ${currentProcess!.currentProcessDetails?.processStatus?.replaceAll('_', ' ').capitalize ?? 'N/A'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Expected Completion: ${DateFormat('dd MMM yyyy').format(currentProcess!.currentProcessDetails?.expectedCompletionDate ?? DateTime.now())}',
                ),
                const SizedBox(height: 16),
                WorkerList(
                    workerData: currentProcess!.currentProcessWorkers ?? []),
                const SizedBox(height: 16),
                if (currentProcess!.currentProcessMaterialsUsed != null)
                  const Column(
                    children: [
                      Text(
                        'Materials Used',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                if (currentProcess!.currentProcessMaterialsUsed != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: currentProcess!.currentProcessMaterialsUsed!
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
}

class RequestCarpenterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RequestCarpenterButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.build),
        label: const Text(
          'Send to Carpenter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class EditEnquiryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditEnquiryButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        label: const Text(
          'Edit Enquiry',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            return WorkersDetailWidget(worker: worker);
          }).toList(),
        ),
      ],
    );
  }
}

class WorkersDetailWidget extends StatelessWidget {
  final detail_model.User worker;
  const WorkersDetailWidget({
    super.key,
    required this.worker,
  });

  @override
  Widget build(BuildContext context) {
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
  }
}
