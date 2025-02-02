import 'package:flutter/material.dart';
import '../../models/enquiry_model.dart';
import '../../app_essentials/colors.dart';
import '../../services/services.dart';
import '../../extensions/context_extensions.dart';

class EnquiryDetailPage extends StatelessWidget {
  final Enquiry enquiry;

  const EnquiryDetailPage({
    Key? key,
    required this.enquiry,
  }) : super(key: key);

  Future<void> _requestCarpenter(BuildContext context) async {
    try {
      await Services().requestCarpenter(enquiry.id!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          enquiry.productName ?? 'Enquiry Details',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Product Details',
              children: [
                _buildDetailRow('Name', enquiry.productName ?? 'N/A'),
                if (enquiry.productNameMal != null)
                  _buildDetailRow('Name (Malayalam)', enquiry.productNameMal!),
                _buildDetailRow(
                    'Description', enquiry.productDescription ?? 'N/A'),
                if (enquiry.productDescriptionMal != null)
                  _buildDetailRow('Description (Malayalam)',
                      enquiry.productDescriptionMal!),
                _buildDetailRow('Dimensions',
                    '${enquiry.productLength ?? 'N/A'} x ${enquiry.productWidth ?? 'N/A'} x ${enquiry.productHeight ?? 'N/A'}'),
                _buildDetailRow('Finish', enquiry.finish ?? 'N/A'),
                _buildDetailRow('Event', enquiry.event ?? 'N/A'),
              ],
            ),
            _buildSection(
              title: 'Customer Information',
              children: [
                _buildDetailRow('Name', enquiry.customerName ?? 'N/A'),
                _buildDetailRow('Phone', enquiry.contactNumber ?? 'N/A'),
                _buildDetailRow('WhatsApp', enquiry.whatsappNumber ?? 'N/A'),
                _buildDetailRow('Email', enquiry.email ?? 'N/A'),
                _buildDetailRow('Address', enquiry.address ?? 'N/A'),
              ],
            ),
            _buildSection(
              title: 'Order Status',
              children: [
                _buildDetailRow(
                    'Priority', enquiry.priority?.toUpperCase() ?? 'N/A'),
                _buildDetailRow('Status', enquiry.status ?? 'N/A'),
                _buildDetailRow(
                    'Enquiry Status', enquiry.enquiryStatus ?? 'N/A'),
                _buildDetailRow(
                    'Estimated Delivery',
                    enquiry.estimatedDeliveryDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        'N/A'),
                if (enquiry.estimatedPrice != null)
                  _buildDetailRow(
                      'Estimated Price', '₹${enquiry.estimatedPrice}'),
                _buildDetailRow(
                    'Material Cost', '₹${enquiry.materialCost ?? 0}'),
                _buildDetailRow(
                    'Ongoing Expense', '₹${enquiry.ongoingExpense ?? 0}'),
                _buildDetailRow(
                    'Over Due', enquiry.overDue == true ? 'Yes' : 'No'),
              ],
            ),
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
      ),
    );
  }
}
