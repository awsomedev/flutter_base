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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      isLoading = true;
    });
    _ordersFuture = Services().getProcessManagerOrders(widget.processManagerId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? const LoadingWidget()
          : FutureBuilder<ProcessManagerOrderResponse>(
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

                final orders = snapshot.data?.data ?? [];

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 110.0,
                      floating: false,
                      pinned: true,
                      stretch: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const [StretchMode.zoomBackground],
                        title: const Text(
                          'Process Orders',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: -0.5,
                          ),
                        ),
                        centerTitle: true,
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (orders.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No orders found',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final order = orders[index];
                              return _buildOrderCard(
                                index,
                                order.orderData,
                                order.process,
                                order.processDetails,
                              );
                            },
                            childCount: orders.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildOrderCard(
      int index, OrderData order, Process process, ProcessDetails details) {
    final bool isOverdue = order.overDue ?? false;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            context.push(
              () => ProcessDetailPage(
                processDetailsId: details.id ?? 0,
                processName: process.name ?? '',
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.productName ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    _buildStatusBadge(
                      isOverdue ? 'OVERDUE' : 'ON TIME',
                      isOverdue ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.productDescription ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildVerticalInfo(
                        'Process',
                        process.name ?? 'N/A',
                        Icons.auto_awesome_rounded,
                        const Color(0xFF6366F1),
                      ),
                    ),
                    Expanded(
                      child: _buildVerticalInfo(
                        'Priority',
                        order.priorityText,
                        Icons.priority_high_rounded,
                        _getPriorityColor(order.priority ?? ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildVerticalInfo(
                        'Status',
                        order.statusText,
                        Icons.info_rounded,
                        _getStatusColor(order.currentProcessStatus ?? ''),
                      ),
                    ),
                    Expanded(
                      child: _buildVerticalInfo(
                        'Delivery',
                        order.formattedDeliveryDate,
                        Icons.calendar_today_rounded,
                        const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        () => ProcessDetailPage(
                          processDetailsId: details.id ?? 0,
                          processName: process.name ?? '',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVerticalInfo(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on_going':
        return const Color(0xFF6366F1);
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }
}
