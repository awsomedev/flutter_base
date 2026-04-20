import 'package:flutter/material.dart';
import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/pages/manager/manager_order_detail_page.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/pages/enquiry/enquiry_detail_page.dart';
import 'package:flutter/cupertino.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key, this.managerId});
  final int? managerId;

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final List<(String, String, IconData)> _filters = [
    ('enquiry', 'Enquiry', Icons.help_outline),
    ('on_going', 'Active', Icons.work_outline),
    ('over_due', 'Overdue', Icons.schedule),
    ('completed', 'Completed', Icons.check_circle_outline),
    ('archived', 'Archived', Icons.archive_outlined),
  ];

  String _selectedStatus = 'enquiry';
  Map<String, List<Enquiry>?> _ordersByStatus = {};
  final Map<String, bool> _loadingStatus = {
    'enquiry': false,
    'on_going': false,
    'over_due': false,
    'completed': false,
    'archived': false,
  };

  @override
  void initState() {
    super.initState();
    _loadOrders(_selectedStatus);
  }

  Future<void> _loadOrders(String status) async {
    if (_loadingStatus[status] == true) return;

    setState(() {
      _loadingStatus[status] = true;
    });

    try {
      late List<Enquiry> orders;
      if (widget.managerId != null) {
        orders = await Services()
            .getManagerOrdersByStatus(widget.managerId!, status);
      } else {
        orders = await Services().getOrdersByStatus(status);
      }
      if (mounted) {
        setState(() {
          _ordersByStatus[status] = orders;
          _loadingStatus[status] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStatus[status] = false;
        });
      }
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red[500]!;
      case 'medium':
        return Colors.orange[500]!;
      case 'low':
        return Colors.green[500]!;
      default:
        return Colors.grey[500]!;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'enquiry':
        return const Color(0xFF6366F1);
      case 'on_going':
        return const Color(0xFF10B981);
      case 'over_due':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'archived':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildOrderCard(Enquiry order, int index) {
    final statusColor = _getStatusColor(_selectedStatus);
    final priorityColor = _getPriorityColor(order.priority);

    // Find the readable label for the status
    String statusLabel = 'Enquiry';
    try {
      statusLabel = _filters.firstWhere((f) => f.$1 == _selectedStatus).$2;
    } catch (_) {
      statusLabel = _selectedStatus.replaceAll('_', ' ').toUpperCase();
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              if (widget.managerId != null) {
                if (order.id != null) {
                  context
                      .push(() => ManagerOrderDetailPage(orderId: order.id!))
                      .then((value) {
                    if (value == true) {
                      _loadOrders(_selectedStatus);
                    }
                  });
                }
              } else {
                context
                    .push(() => EnquiryDetailPage(enquiryId: order.id!))
                    .then((value) {
                  if (value == true) {
                    _loadOrders(_selectedStatus);
                  }
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                              order.productName ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildBadge(
                                  statusLabel,
                                  statusColor,
                                ),
                                const SizedBox(width: 8),
                                _buildBadge(
                                  order.priority?.toUpperCase() ?? 'NORMAL',
                                  priorityColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildProgressCircle(order, statusColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.event_note_rounded,
                          order.estimatedDeliveryDate
                                  ?.toString()
                                  .split(' ')[0] ??
                              'Not Set',
                          const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.location_on_rounded,
                          order.loacation ?? 'Not Set',
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  if (order.productDescription != null &&
                      order.productDescription!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Text(
                        order.productDescription!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProgressCircle(Enquiry order, Color color) {
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: order.completionPercentage != null
                  ? order.completionPercentage! / 100
                  : 0.0,
              strokeWidth: 4,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            order.completionPercentage != null
                ? '${order.completionPercentage!.toInt()}%'
                : '0%',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 10, bottom: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedStatus == filter.$1;
          final color = _getStatusColor(filter.$1);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ChoiceChip(
                label: Row(
                  children: [
                    Icon(
                      filter.$3,
                      size: 16,
                      color: isSelected ? Colors.white : color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedStatus = filter.$1;
                    });
                    _loadOrders(_selectedStatus);
                  }
                },
                selectedColor: color,
                backgroundColor: color.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                side: BorderSide(
                  color: isSelected ? color : color.withOpacity(0.1),
                  width: 1,
                ),
                elevation: isSelected ? 4 : 0,
                shadowColor: color.withOpacity(0.3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                showCheckmark: false,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _ordersByStatus[_selectedStatus];
    final isLoading = _loadingStatus[_selectedStatus] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 110.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF6366F1),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -1,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildFilterBar(),
          ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CupertinoActivityIndicator(radius: 16),
              ),
            )
          else if (orders == null || orders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_selectedStatus)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.inbox_rounded,
                          size: 64,
                          color: _getStatusColor(_selectedStatus),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No ${_filters.firstWhere((f) => f.$1 == _selectedStatus).$2} Orders',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pull down to refresh or check other sections.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 0, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildOrderCard(orders[index], index),
                  childCount: orders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
