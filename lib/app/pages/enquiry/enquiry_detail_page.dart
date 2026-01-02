import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/enquiry_detail_response_model.dart';
import 'package:madeira/app/pages/enquiry/create_enquiry_page.dart';
import 'package:madeira/app/widgets/audio_player.dart';
import 'package:madeira/app/widgets/progress_indicator_widget.dart';

import '../../models/enquiry_detail_response_model.dart' as detail_model;
import '../../app_essentials/colors.dart';
import '../../services/services.dart';
import '../../extensions/context_extensions.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
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
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Text(
                enquiryDetail.orderData?.productName ?? 'Enquiry Details',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
              backgroundColor: const Color(0xFF667eea),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                ),
              ),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const Text(
                        'Over Due',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
    super.key,
    required this.enquiryDetail,
    required this.isCarpenterRequested,
    required this.onCarpenterRequested,
  });

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
      padding: const EdgeInsets.all(20),
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
                AudioPlayer(audioUrl: audio.audio.toString().toUrl),
            ],
          ),
          const SizedBox(height: 24),
          Section(
            title: 'Product Details',
            icon: Icons.inventory_2,
            color: const Color(0xFF667eea),
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
              const SizedBox(height: 16),
              ProgressIndicatorWidget(
                totalSteps: 100,
                currentStep: (enquiryDetail.completionPercentage ?? 0).toInt(),
                height: 10,
              ),
            ],
          ),
          Section(
            title: 'Customer Information',
            icon: Icons.person,
            color: const Color(0xFF4ECDC4),
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
            icon: Icons.track_changes,
            color: const Color(0xFFFF6B6B),
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
    if (enquiryDetail.enquiryList == null ||
        enquiryDetail.enquiryList?.isEmpty == true) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Custom Enquiries', Icons.question_answer, const Color(0xFF95E1D3)),
        const SizedBox(height: 16),
        ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF95E1D3).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF95E1D3).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF95E1D3).withOpacity(0.2),
                                const Color(0xFF95E1D3).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            enquiryDetail.enquiryList![index].enquiryType ??
                                'N/A',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: enquiryDetail.enquiryList!.length),
      ],
    );
  }
}

Widget _buildSectionHeader(String title, IconData icon, Color color) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
          letterSpacing: 0.3,
        ),
      ),
    ],
  );
}

class Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const Section({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, icon, color),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
        _buildSectionHeader(
            'Product Images', Icons.photo_library, const Color(0xFFFFB6B9)),
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 280,
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: image.image?.toString().toUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFB6B9).withOpacity(0.1),
                              const Color(0xFFFFB6B9).withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFB6B9).withOpacity(0.1),
                              const Color(0xFFFFB6B9).withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.error, size: 48),
                        ),
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
    if (materials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Materials', Icons.inventory, const Color(0xFFFEC8D8)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFEC8D8).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFFEC8D8).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material?.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      material?.description ?? 'N/A',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFEC8D8).withOpacity(0.2),
                                const Color(0xFFFEC8D8).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Qty: ${material?.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF48BB78), Color(0xFF38A169)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF48BB78).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            '₹${material?.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        _buildSectionHeader(
            'Team Information', Icons.groups, const Color(0xFFBAE1FF)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFBAE1FF).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFBAE1FF).withOpacity(0.3),
              width: 1,
            ),
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
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFBAE1FF).withOpacity(0.3),
                            const Color(0xFFBAE1FF).withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star,
                          color: Color(0xFF667eea), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Main Manager',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFDAB9).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFFDAB9).withOpacity(0.3),
                width: 1,
              ),
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
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFDAB9).withOpacity(0.3),
                              const Color(0xFFFFDAB9).withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.construction,
                            color: Color(0xFFFF8C00), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Carpenter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
              return Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A5A5).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFD4A5A5).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
        _buildSectionHeader(
            'Completed Processes', Icons.check_circle, const Color(0xFF10B981)),
        const SizedBox(height: 16),
        ...completedProcesses!.map((process) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
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
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.done_all,
                            color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          process.completedProcess?.name ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    process.completedProcess?.description ?? 'N/A',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        'Status',
                        process.completedProcessDetails?.processStatus ?? 'N/A',
                        Icons.info_outline,
                        const Color(0xFF6B7280),
                      ),
                      _buildInfoChip(
                        'Workers Salary',
                        '₹${process.completedProcessDetails?.workersSalary ?? 'N/A'}',
                        Icons.payment,
                        const Color(0xFF6B7280),
                      ),
                      _buildInfoChip(
                        'Material Price',
                        '₹${process.completedProcessDetails?.materialPrice ?? 'N/A'}',
                        Icons.inventory,
                        const Color(0xFF6B7280),
                      ),
                      _buildInfoChip(
                        'Total',
                        '₹${process.completedProcessDetails?.totalPrice ?? 'N/A'}',
                        Icons.account_balance_wallet,
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (process.completedProcessDetails?.images != null &&
                      process.completedProcessDetails!.images!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Process Images',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 220,
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
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
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
                      child: Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 16, color: Color(0xFF718096)),
                          const SizedBox(width: 6),
                          Text(
                            'Expected: ${DateFormat('dd MMM yyyy').format(process.completedProcessDetails!.expectedCompletionDate!)}',
                            style: const TextStyle(
                                color: Color(0xFF718096), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  if (process.completedProcessDetails?.completionDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 16, color: Color(0xFF48BB78)),
                          const SizedBox(width: 6),
                          Text(
                            'Completed: ${DateFormat('dd MMM yyyy').format(process.completedProcessDetails!.completionDate!)}',
                            style: const TextStyle(
                                color: Color(0xFF48BB78),
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
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

Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 13, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );
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
        _buildSectionHeader(
            'Current Process', Icons.sync, const Color(0xFF3B82F6)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
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
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.hourglass_top,
                          color: Color(0xFF3B82F6), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        currentProcess!.currentProcess?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentProcess!.currentProcess?.description ?? 'N/A',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings,
                              size: 18, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          Text(
                            'Status: ${currentProcess!.currentProcessDetails?.processStatus?.replaceAll('_', ' ').capitalize ?? 'N/A'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Color(0xFF718096)),
                    const SizedBox(width: 6),
                    Text(
                      'Expected: ${DateFormat('dd MMM yyyy').format(currentProcess!.currentProcessDetails?.expectedCompletionDate ?? DateTime.now())}',
                      style: const TextStyle(
                          color: Color(0xFF718096), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WorkerList(
                    workerData: currentProcess!.currentProcessWorkers ?? []),
                const SizedBox(height: 16),
                if (currentProcess!.currentProcessMaterialsUsed != null)
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Materials Used',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(height: 12),
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
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.inventory_2_outlined,
                                              size: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Qty: ${materialUsedInProcess?.quantity ?? 'N/A'}',
                                              style: const TextStyle(
                                                color: Color(0xFF374151),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.currency_rupee,
                                              size: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                            Text(
                                              '${materialUsedInProcess?.materialPrice ?? 'N/A'}',
                                              style: const TextStyle(
                                                color: Color(0xFF374151),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Total: ₹${materialUsedInProcess?.totalPrice ?? 'N/A'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.build, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Send to Carpenter',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Edit Enquiry',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
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
        const SizedBox(height: 16),
        const Text(
          'Materials Used',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: process.materialsUsed!.map((material) {
            final materialDetails = material.materialDetails;
            final materialUsedInProcess = material.materialUsedInProcess;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
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
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Qty: ${materialUsedInProcess?.quantity ?? 'N/A'}',
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.currency_rupee,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                            Text(
                              '${materialUsedInProcess?.materialPrice ?? 'N/A'}',
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Total: ₹${materialUsedInProcess?.totalPrice ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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
    if (workerData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workers',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF6B7280),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF48BB78).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            size: 14,
                            color: Color(0xFF48BB78),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${worker.salaryPerHr ?? 'N/A'}/hr',
                            style: const TextStyle(
                              color: Color(0xFF48BB78),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Color(0xFF667eea),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${worker.phone}',
                            style: const TextStyle(
                              color: Color(0xFF667eea),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
