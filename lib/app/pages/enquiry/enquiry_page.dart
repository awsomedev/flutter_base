import 'package:flutter/material.dart';
import '../../models/enquiry_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';
import 'enquiry_detail_page.dart';
import 'create_enquiry_page.dart';

class EnquiryPage extends StatefulWidget {
  const EnquiryPage({Key? key}) : super(key: key);

  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  List<Enquiry> enquiries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEnquiries();
  }

  Future<void> fetchEnquiries() async {
    try {
      final enquiryList = await Services().getEnquiries();
      if (mounted) {
        setState(() {
          enquiries = enquiryList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildEnquiryCard(Enquiry enquiry) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnquiryDetailPage(enquiryId: enquiry.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enquiry.productName ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          enquiry.customerName ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(enquiry.priority),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      enquiry.priority?.toUpperCase() ?? 'N/A',
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.phone,
                    label: enquiry.contactNumber ?? 'N/A',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: Icons.calendar_today,
                    label: enquiry.estimatedDeliveryDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        'N/A',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      case 'urgent':
        return Colors.red.shade700;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Enquiries',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: enquiries.length,
              itemBuilder: (context, index) =>
                  _buildEnquiryCard(enquiries[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEnquiryPage(),
            ),
          );
          if (result == true) {
            fetchEnquiries();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: AppColors.background,
        ),
      ),
    );
  }
}
