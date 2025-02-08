import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import '../../models/enquiry_model.dart';
import '../../models/enquiry_detail_response_model.dart' as detail_model;
import '../../app_essentials/colors.dart';
import '../../services/services.dart';
import '../../extensions/context_extensions.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EnquiryDetailPage extends StatelessWidget {
  final int enquiryId;

  const EnquiryDetailPage({
    Key? key,
    required this.enquiryId,
  }) : super(key: key);

  Future<void> _requestCarpenter(BuildContext context) async {
    try {
      await Services().requestCarpenter(enquiryId);
      if (context.mounted) {
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
    final images = enquiryDetail.orderData.images;
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
          itemCount: enquiryDetail.materials.length,
          itemBuilder: (context, index) {
            final material = enquiryDetail.materials[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(material.description),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantity: ${material.quantity}'),
                        Text('Price: ₹${material.price}'),
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
                _buildDetailRow('Name', enquiryDetail.mainManager.name),
                _buildDetailRow('Email', enquiryDetail.mainManager.email),
                _buildDetailRow('Phone', enquiryDetail.mainManager.phone),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (enquiryDetail.carpenterEnquiryData.carpenterUser != null)
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
                    enquiryDetail.carpenterEnquiryData.carpenterUser.name,
                  ),
                  _buildDetailRow(
                    'Email',
                    enquiryDetail.carpenterEnquiryData.carpenterUser.email,
                  ),
                  _buildDetailRow(
                    'Phone',
                    enquiryDetail.carpenterEnquiryData.carpenterUser.phone,
                  ),
                ],
              ),
            ),
          ),
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
              _buildDetailRow('Name', orderData.productName ?? 'N/A'),
              if (orderData.productNameMal != null)
                _buildDetailRow('Name (Malayalam)', orderData.productNameMal!),
              _buildDetailRow(
                  'Description', orderData.productDescription ?? 'N/A'),
              if (orderData.productDescriptionMal != null)
                _buildDetailRow('Description (Malayalam)',
                    orderData.productDescriptionMal!),
              _buildDetailRow('Dimensions',
                  '${orderData.productLength ?? 'N/A'} x ${orderData.productWidth ?? 'N/A'} x ${orderData.productHeight ?? 'N/A'}'),
              _buildDetailRow('Finish', orderData.finish ?? 'N/A'),
              _buildDetailRow('Event', orderData.event ?? 'N/A'),
            ],
          ),
          _buildSection(
            title: 'Customer Information',
            children: [
              _buildDetailRow('Name', orderData.customerName ?? 'N/A'),
              _buildDetailRow('Phone', orderData.contactNumber ?? 'N/A'),
              _buildDetailRow('WhatsApp', orderData.whatsappNumber ?? 'N/A'),
              _buildDetailRow('Email', orderData.email ?? 'N/A'),
              _buildDetailRow('Address', orderData.address ?? 'N/A'),
            ],
          ),
          _buildSection(
            title: 'Order Status',
            children: [
              _buildDetailRow(
                  'Priority', orderData.priority?.toUpperCase() ?? 'N/A'),
              _buildDetailRow('Status', orderData.status ?? 'N/A'),
              _buildDetailRow(
                  'Enquiry Status', orderData.enquiryStatus ?? 'N/A'),
              _buildDetailRow('Completion',
                  '${(enquiryDetail.completionPercentage * 100).toStringAsFixed(1)}%'),
              _buildDetailRow(
                  'Estimated Delivery',
                  orderData.estimatedDeliveryDate
                          ?.toLocal()
                          .toString()
                          .split(' ')[0] ??
                      'N/A'),
              if (orderData.estimatedPrice != null)
                _buildDetailRow(
                    'Estimated Price', '₹${orderData.estimatedPrice}'),
              _buildDetailRow(
                  'Material Cost', '₹${orderData.materialCost ?? 0}'),
              _buildDetailRow(
                  'Ongoing Expense', '₹${orderData.ongoingExpense ?? 0}'),
              _buildDetailRow(
                  'Over Due', orderData.overDue == true ? 'Yes' : 'No'),
            ],
          ),
          _buildMaterialsList(enquiryDetail),
          const SizedBox(height: 24),
          _buildTeamSection(enquiryDetail),
          const SizedBox(height: 24),
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
        future: Services().getEnquiryDetails(enquiryId),
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
                enquiryDetail.orderData.productName ?? 'Enquiry Details',
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
