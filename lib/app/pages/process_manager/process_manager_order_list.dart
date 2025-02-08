import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/models/process_manager_order_model.dart';
import 'package:madeira/app/models/process_model.dart';
import 'package:madeira/app/pages/process_manager/process_detail_page.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:madeira/app/widgets/error_widget.dart';

class ProcessManagerOrderList extends StatefulWidget {
  final int processManagerId;

  const ProcessManagerOrderList({
    super.key,
    required this.processManagerId,
  });

  @override
  State<ProcessManagerOrderList> createState() =>
      _ProcessManagerOrderListState();
}

class _ProcessManagerOrderListState extends State<ProcessManagerOrderList> {
  late Future<ProcessManagerOrderResponse> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = Services().getProcessManagerOrders(widget.processManagerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Orders'),
      ),
      body: FutureBuilder<ProcessManagerOrderResponse>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: _loadOrders,
            );
          }

          if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(
              child: Text('No orders found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.data.length,
            itemBuilder: (context, index) {
              final order = snapshot.data!.data[index];
              return _buildOrderCard(order.orderData, order.process);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderData order, Process process) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push(
            () => ProcessDetailPage(
              orderId: order.id ?? 0,
              processDetailsId: process.id ?? 0,
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
                    child: Text(
                      order.productName ?? '',
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
                      color: order.overDue ?? false
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.overDue ?? false ? 'OVERDUE' : 'ON TIME',
                      style: TextStyle(
                        color: order.overDue ?? false
                            ? AppColors.error
                            : AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.productDescription ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoChip(
                label: 'Process',
                value: '${process.name} (${process.nameMal})',
                color: _getPriorityColor(order.priority ?? ''),
              ),
              Row(
                children: [
                  _buildInfoChip(
                    label: 'Priority',
                    value: order.priorityText,
                    color: _getPriorityColor(order.priority ?? ''),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    label: 'Status',
                    value: order.statusText,
                    color: _getStatusColor(order.currentProcessStatus ?? ''),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery: ${order.formattedDeliveryDate}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _acceptOrder(order.currentProcess ?? 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptOrder(int processId) async {
    final result = await ConfirmationDialog.show(
      context: context,
      title: 'Confirmation',
      message: 'Are you sure you want to accept this order?',
    );
    if (result != true) {
      return;
    }
    try {
      await Services().acceptProcessOrder(processId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order accepted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadOrders(); // Reload the list after accepting
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on_going':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
