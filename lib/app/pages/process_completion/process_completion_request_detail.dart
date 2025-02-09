import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/process_completion_request_model.dart';
import 'package:madeira/app/models/process_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProcessCompletionRequestDetail extends StatefulWidget {
  final int orderId;

  const ProcessCompletionRequestDetail({
    super.key,
    required this.orderId,
  });

  @override
  State<ProcessCompletionRequestDetail> createState() =>
      _ProcessCompletionRequestDetailState();
}

class _ProcessCompletionRequestDetailState
    extends State<ProcessCompletionRequestDetail> {
  late Future<ProcessCompletionRequestVerification> _requestFuture;

  @override
  void initState() {
    super.initState();
    _requestFuture =
        Services().getProcessCompletionRequestVerification(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Completion Request'),
      ),
      body: FutureBuilder<ProcessCompletionRequestVerification>(
        future: _requestFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _requestFuture = Services()
                      .getProcessCompletionRequestVerification(widget.orderId);
                });
              },
            );
          }

          final request = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductSection(request.orderData),
                const SizedBox(height: 24),
                _buildProcessSection(request.process),
                const SizedBox(height: 24),
                _buildProcessDetailsSection(request.processDetails),
                const SizedBox(height: 24),
                if (request.materials.isNotEmpty) ...[
                  _buildMaterialsSection(request.materials),
                  const SizedBox(height: 24),
                ],
                _buildActionButtons(request.processDetails),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection(ProcessCompletionRequestOrderData orderData) {
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
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: orderData.priority.toLowerCase() == 'high'
                        ? AppColors.error
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    orderData.priority.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (orderData.images.isNotEmpty) ...[
              CarouselSlider.builder(
                itemCount: orderData.images.length,
                options: CarouselOptions(
                  height: 250,
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: orderData.images.length > 1,
                  autoPlay: orderData.images.length > 1,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                itemBuilder: (context, index, realIndex) {
                  final image = orderData.images[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: image.image.toImageUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            Text(
              orderData.productName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              orderData.productDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dimensions',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'L: ${orderData.productLength}″ × W: ${orderData.productWidth}″ × H: ${orderData.productHeight}″',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finish',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderData.finish,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderData.event,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Date',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderData.estimatedDeliveryDate ?? 'Not set',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessSection(Process process) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Process',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              process.name ?? 'Unknown Process',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (process.description != null) ...[
              const SizedBox(height: 8),
              Text(
                process.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessDetailsSection(ProcessCompletionRequestDetails details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Process Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (details.images.isNotEmpty) ...[
              CarouselSlider.builder(
                itemCount: details.images.length,
                options: CarouselOptions(
                  height: 250,
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: details.images.length > 1,
                  autoPlay: details.images.length > 1,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                itemBuilder: (context, index, realIndex) {
                  final image = details.images[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: image.image.toImageUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: details.overDue
                              ? AppColors.error
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          details.processStatus.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected Completion',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        details.expectedCompletionDate ?? 'Not set',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workers Salary',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${details.workersSalary}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Material Price',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${details.materialPrice}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total Price',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '₹${details.totalPrice}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(List<MaterialUsed> materials) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materials Used',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.material.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${material.quantity}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Price: ₹${material.materialPrice}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Total: ₹${material.totalPrice}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
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

  Widget _buildActionButtons(ProcessCompletionRequestDetails process) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                bool? res = await ConfirmationDialog.show(
                    title: "Confirmation",
                    message: "Are you sure you want to reject this process?",
                    context: context);
                if (res == true) {
                  await Services().rejectProcessVerification(process.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Process verification rejected successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Reject',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              try {
                bool? res = await ConfirmationDialog.show(
                    title: "Confirmation",
                    message: "Are you sure you want to approve this process?",
                    context: context);
                if (res == true) {
                  await Services().acceptProcessVerification(process.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Process verification approved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Approve',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
