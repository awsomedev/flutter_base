import 'package:flutter/material.dart';
import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/pages/manager/manager_order_detail_page.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/pages/enquiry/enquiry_detail_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key, this.managerId});
  final int? managerId;

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<(String, String, IconData)> _tabs = [
    ('enquiry', 'Enquiry', Icons.help_outline),
    ('on_going', 'Active', Icons.work_outline),
    ('over_due', 'Overdue', Icons.schedule),
    ('completed', 'Completed', Icons.check_circle_outline),
    ('archived', 'Archived', Icons.archive_outlined),
  ];

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
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadOrders(_tabs[0].$1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final status = _tabs[_tabController.index].$1;
      _loadOrders(status);
    }
  }

  Future<void> _loadOrders(String status) async {
    if (!_loadingStatus[status]!) {
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
        setState(() {
          _ordersByStatus[status] = orders;
          _loadingStatus[status] = false;
        });
      } catch (e) {
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
        return const Color(0xFFE53E3E);
      case 'medium':
        return const Color.fromARGB(255, 198, 90, 2);
      case 'low':
        return const Color(0xFF38A169);
      default:
        return const Color(0xFF718096);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'enquiry':
        return const Color.fromARGB(255, 1, 86, 166);
      case 'on_going':
        return const Color.fromARGB(255, 41, 77, 17);
      case 'over_due':
        return const Color.fromARGB(255, 198, 0, 0);
      case 'completed':
        return const Color.fromARGB(255, 0, 116, 54);
      case 'archived':
        return const Color.fromARGB(255, 0, 0, 0);
      default:
        return const Color.fromARGB(255, 0, 0, 0);
    }
  }

  Widget _buildOrderCard(Enquiry order, {int? managerId}) {
    final statusColor = _getStatusColor(_tabs[_tabController.index].$1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (managerId != null) {
              if (order.id != null) {
                context
                    .push(() => ManagerOrderDetailPage(orderId: order.id!))
                    .then((value) {
                  if (value == true) {
                    _loadOrders(_tabs[_tabController.index].$1);
                  }
                });
              }
            } else {
              context
                  .push(() => EnquiryDetailPage(enquiryId: order.id!))
                  .then((value) {
                if (value == true) {
                  _loadOrders(_tabs[_tabController.index].$1);
                }
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.productName ?? 'Unnamed Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _getStatusColor(
                                            _tabs[_tabController.index].$1)
                                        .withOpacity(0.2),
                                  ),
                                  // gradient: LinearGradient(
                                  //   colors: [
                                  //     _getStatusColor(
                                  //             _tabs[_tabController.index].$1)
                                  //         .withOpacity(0.15),
                                  //     _getStatusColor(
                                  //             _tabs[_tabController.index].$1)
                                  //         .withOpacity(0.08),
                                  //   ],
                                  // ),
                                  borderRadius: BorderRadius.circular(8),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: _getStatusColor(
                                  //             _tabs[_tabController.index].$1)
                                  //         .withOpacity(0.3),
                                  //     blurRadius: 4,
                                  //     offset: const Offset(0, 2),
                                  //   ),
                                  // ],
                                ),
                                child: Text(
                                  _tabs[_tabController.index].$2,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(
                                        _tabs[_tabController.index].$1),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Priority badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _getPriorityColor(order.priority)
                                        .withOpacity(0.2),
                                  ),
                                  // gradient: LinearGradient(
                                  //   colors: [
                                  //     _getPriorityColor(order.priority)
                                  //         .withOpacity(0.15),
                                  //     _getPriorityColor(order.priority)
                                  //         .withOpacity(0.08),
                                  //   ],
                                  // ),
                                  borderRadius: BorderRadius.circular(8),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: _getPriorityColor(order.priority)
                                  //         .withOpacity(0.3),
                                  //     blurRadius: 4,
                                  //     offset: const Offset(0, 2),
                                  //   ),
                                  // ],
                                ),
                                child: Text(
                                  order.priority?.toUpperCase() ?? 'NORMAL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getPriorityColor(order.priority),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Progress circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFF8FAFC),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: statusColor.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              value: order.completionPercentage != null
                                  ? order.completionPercentage! / 100
                                  : 0.0,
                              strokeWidth: 3,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                          Text(
                            order.completionPercentage != null
                                ? '${order.completionPercentage!.toInt()}%'
                                : '0%',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (order.productDescription != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    order.productDescription!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Info row - more compact
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactInfoItem(
                        Icons.calendar_today_outlined,
                        order.estimatedDeliveryDate?.toString().split(' ')[0] ??
                            'Not Set',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCompactInfoItem(
                        Icons.location_on_outlined,
                        order.loacation ?? 'Not Set',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfoItem(IconData icon, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3182CE).withOpacity(0.1),
                const Color(0xFF3182CE).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3182CE).withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFF3182CE),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(String status) {
    if (_loadingStatus[status] ?? false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading orders...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final orders = _ordersByStatus[status];
    if (orders == null || orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 32,
                color: _getStatusColor(status),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrders(status),
      color: _getStatusColor(status),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) =>
            _buildOrderCard(orders[index], managerId: widget.managerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: _tabs
                  .map((tab) => Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tab.$3, size: 18),
                              const SizedBox(width: 6),
                              Text(tab.$2),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildTabContent(tab.$1)).toList(),
      ),
    );
  }
}
