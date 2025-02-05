import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/process_detail_model.dart';
import 'package:madeira/app/models/user_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class ProcessDetailPage extends StatefulWidget {
  final int orderId;

  const ProcessDetailPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<ProcessDetailPage> createState() => _ProcessDetailPageState();
}

class _ProcessDetailPageState extends State<ProcessDetailPage> {
  late Future<ProcessDetailResponse> _detailFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    _detailFuture = Services().getProcessDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Details'),
      ),
      body: FutureBuilder<ProcessDetailResponse>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: _loadDetails,
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final data = snapshot.data!.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(
                  data.orderData.images
                      .where((e) => e.id != null && e.image != null)
                      .map((e) => ProcessImage(id: e.id!, image: e.image!))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _buildProductDetails(data.orderData),
                const SizedBox(height: 20),
                _buildProcessDetails(data.processDetails),
                const SizedBox(height: 20),
                _buildManagerDetails(data.mainManager, data.processManager),
                const SizedBox(height: 20),
                _buildWorkersDetails(data.workersData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<ProcessImage> images) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildProductDetails(ProcessOrderData order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Product Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order.overDue
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.overDue ? 'OVERDUE' : 'ON TIME',
                    style: TextStyle(
                      color:
                          order.overDue ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', order.productName),
            _buildDetailRow('Description', order.productDescription),
            _buildDetailRow('Status', order.status.toUpperCase()),
            _buildDetailRow('Priority', order.priority.toUpperCase()),
            _buildDetailRow(
              'Dimensions',
              '${order.productLength}x${order.productWidth}x${order.productHeight}',
            ),
            _buildDetailRow('Finish', order.finish),
            _buildDetailRow('Event', order.event),
            if (order.estimatedDeliveryDate != null)
              _buildDetailRow(
                'Estimated Delivery',
                DateFormat('dd MMM yyyy').format(order.estimatedDeliveryDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessDetails(ProcessDetails details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Process Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Status', details.processStatus.toUpperCase()),
            if (details.expectedCompletionDate != null)
              _buildDetailRow(
                'Expected Completion',
                DateFormat('dd MMM yyyy')
                    .format(details.expectedCompletionDate!),
              ),
            if (details.completionDate != null)
              _buildDetailRow(
                'Completion Date',
                DateFormat('dd MMM yyyy').format(details.completionDate!),
              ),
            if (details.requestAcceptedDate != null)
              _buildDetailRow(
                'Request Accepted',
                DateFormat('dd MMM yyyy').format(details.requestAcceptedDate!),
              ),
            if (details.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Process Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.8,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                ),
                items: details.images.map((image) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildManagerDetails(User mainManager, User processManager) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Managers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Main Manager',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildDetailRow('Name', mainManager.name ?? 'N/A'),
            _buildDetailRow('Phone', mainManager.phone ?? 'N/A'),
            const SizedBox(height: 16),
            const Text(
              'Process Manager',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildDetailRow('Name', processManager.name ?? 'N/A'),
            _buildDetailRow('Phone', processManager.phone ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersDetails(List<User> workers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.name ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              worker.phone ?? 'N/A',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
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
