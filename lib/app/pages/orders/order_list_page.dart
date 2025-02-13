import 'package:flutter/material.dart';
import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/pages/manager/manager_order_detail_page.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/app_essentials/colors.dart';
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
  final List<(String, String)> _tabs = [
    ('enquiry', 'Enquiry'),
    ('on_going', 'On Going'),
    ('over_due', 'Over due'),
    ('completed', 'Completed'),
    ('archived', 'Archived'),
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
    _loadOrders(_tabs[0].$1); // Load initial tab
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
        // if (mounted) {
        //   context.showSnackBar(
        //     'Failed to load orders: $e',
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //   );
        // }
      }
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderCard(Enquiry order, {int? managerId}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.productName ?? 'Unnamed Product',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(order.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getPriorityColor(order.priority),
                      ),
                    ),
                    child: Text(
                      order.priority?.toUpperCase() ?? 'NO PRIORITY',
                      style: TextStyle(
                        color: _getPriorityColor(order.priority),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.productDescription != null) ...[
                Text(
                  order.productDescription!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
              ],
              // Row(
              //   children: [
              //     const Icon(Icons.person_outline,
              //         size: 16, color: Colors.grey),
              //     const SizedBox(width: 4),
              //     Text(
              //       order.customerName ?? 'Unknown Customer',
              //       style: Theme.of(context).textTheme.bodyMedium,
              //     ),
              //     const SizedBox(width: 16),
              //     const Icon(Icons.phone_outlined,
              //         size: 16, color: Colors.grey),
              //     const SizedBox(width: 4),
              //     Text(
              //       order.contactNumber ?? 'No Contact',
              //       style: Theme.of(context).textTheme.bodyMedium,
              //     ),
              //   ],
              // ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery: ${order.estimatedDeliveryDate?.toString().split(' ')[0] ?? 'Not Set'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Status: ${order.enquiryStatus ?? 'Not Set'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String status) {
    if (_loadingStatus[status] ?? false) {
      return const Center(child: CircularProgressIndicator());
    }

    final orders = _ordersByStatus[status];
    if (orders == null || orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrders(status),
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
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs
              .map((tab) => Tab(
                    text: tab.$2,
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildTabContent(tab.$1)).toList(),
      ),
    );
  }
}
