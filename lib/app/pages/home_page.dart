import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/models/user_static.dart';
import 'package:madeira/app/pages/app_drawer.dart';
import 'package:madeira/app/pages/decorations/decorations.dart';
import 'package:madeira/app/pages/decorations/enquiries.dart';
import 'package:madeira/app/pages/enquiry/enquiry_page.dart';
import 'package:madeira/app/pages/inventory/category_list_page.dart';
import 'package:madeira/app/pages/inventory/product_category_list_page.dart';
import 'package:madeira/app/pages/orders/order_list_page.dart';
import 'package:madeira/app/pages/process/process_list_page.dart';
import 'package:madeira/app/pages/process_completion/process_completion_request_list.dart';
import 'package:madeira/app/pages/process_manager/process_manager_order_list.dart';
import 'package:madeira/app/pages/requests/request_list.dart';
import 'package:madeira/app/pages/sale/sale_list_page.dart';
import 'package:madeira/app/pages/users/user_list_page.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/admin_only_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> sections;

  Future<void> navigateToPage(String page) async {
    switch (page) {
      case 'Inventory':
        context.push(() => const CategoryListPage());
        break;
      case 'Products':
        context.push(() => const ProductCategoryListPage());
        break;
      case 'Users':
        context.push(() => const UserListPage());
        break;
      case 'Process':
        context.push(() => const ProcessListPage());
        break;
      case 'Enquiry':
        context.push(() => const EnquiryPage());
        break;
      case 'Decorations':
        context.push(() => const DecorationsPage());
        break;
      case 'Decoration Enquiry':
        context.push(() => const DecorationEnquiriesPage());
        break;
      case 'Orders':
        context.push(() => const OrderListPage());
        break;
      case 'Carpenter Requests':
        context.push(() => const RequestListPage());
        break;
      case 'Managers Orders':
        var userId = await Services().getUserId();
        context.push(
          () => OrderListPage(
            managerId: int.parse(userId!),
          ),
        );
        break;
      case 'Process Managers Orders':
        var userId = await Services().getUserId();
        context.push(() => ProcessManagerOrderList(
              processManagerId: int.parse(userId!),
            ));
        break;
      case 'Process Completion Requests':
        context.push(() => const ProcessCompletionRequestList());
        break;
      case 'Sale':
        context.push(() => SaleListPage());
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    if (AdminTracker.isAdmin) {
      sections = [
        {
          'title': 'Enquiry',
          'icon': Icons.question_answer,
          'color': Colors.blue,
          'description': 'Manage customer enquiries',
          'image': '💬'
        },
        {
          'title': 'Orders',
          'icon': Icons.shopping_cart,
          'color': Colors.green,
          'description': 'View and manage orders',
          'image': '🛒'
        },
        {
          'title': 'Inventory',
          'icon': Icons.inventory,
          'color': Colors.purple,
          'description': 'Stock management',
          'image': '📦'
        },
        {
          'title': 'Products',
          'icon': Icons.inventory_2,
          'color': Colors.orange,
          'description': 'Product catalog',
          'image': '🏪'
        },
        {
          'title': 'Decorations',
          'icon': Icons.access_alarm,
          'color': Colors.pink,
          'description': 'Decoration services',
          'image': '🎨'
        },
        {
          'title': 'Decoration Enquiry',
          'icon': Icons.design_services,
          'color': Colors.brown,
          'description': 'Decoration requests',
          'image': '🎭'
        },
        {
          'title': 'Users',
          'icon': Icons.people,
          'color': Colors.blueGrey,
          'description': 'User management',
          'image': '👥'
        },
        {
          'title': 'Process',
          'icon': Icons.production_quantity_limits,
          'color': Colors.teal,
          'description': 'Process management',
          'image': '⚙️'
        },
        {
          'title': 'Carpenter Requests',
          'icon': Icons.task,
          'color': Colors.deepOrange,
          'description': 'Carpenter services',
          'image': '🔨'
        },
        {
          'title': 'Managers Orders',
          'icon': Icons.manage_accounts,
          'color': Colors.indigo,
          'description': 'Manager orders',
          'image': '👔'
        },
        {
          'title': 'Process Managers Orders',
          'icon': Icons.manage_accounts_outlined,
          'color': Colors.lime,
          'description': 'Process manager orders',
          'image': '🏭'
        },
        {
          'title': 'Process Completion Requests',
          'icon': Icons.check_box_outline_blank,
          'color': Colors.lightGreen,
          'description': 'Completion requests',
          'image': '✅'
        },
        {
          'title': 'Sale',
          'icon': Icons.money,
          'color': Colors.green,
          'description': 'Sales management',
          'image': '💰'
        },
      ];
    } else if (AdminTracker.isEnqTaker) {
      sections = [
        {
          'title': 'Enquiry',
          'icon': Icons.question_answer,
          'color': Colors.blue,
          'description': 'Manage customer enquiries',
          'image': '💬'
        },
        {
          'title': 'Inventory',
          'icon': Icons.inventory,
          'color': Colors.purple,
          'description': 'Stock management',
          'image': '📦'
        },
        {
          'title': 'Products',
          'icon': Icons.inventory_2,
          'color': Colors.orange,
          'description': 'Product catalog',
          'image': '🏪'
        },
        {
          'title': 'Decorations',
          'icon': Icons.access_alarm,
          'color': Colors.pink,
          'description': 'Decoration services',
          'image': '🎨'
        },
        {
          'title': 'Decoration Enquiry',
          'icon': Icons.request_quote,
          'color': Colors.brown,
          'description': 'Decoration requests',
          'image': '🎭'
        },
        {
          'title': 'Process',
          'icon': Icons.production_quantity_limits,
          'color': Colors.teal,
          'description': 'Process management',
          'image': '⚙️'
        },
        {
          'title': 'Carpenter Requests',
          'icon': Icons.request_quote,
          'color': Colors.deepOrange,
          'description': 'Carpenter services',
          'image': '🔨'
        },
        {
          'title': 'Managers Orders',
          'icon': Icons.request_quote,
          'color': Colors.indigo,
          'description': 'Manager orders',
          'image': '👔'
        },
        {
          'title': 'Process Managers Orders',
          'icon': Icons.request_quote,
          'color': Colors.lime,
          'description': 'Process manager orders',
          'image': '🏭'
        },
        {
          'title': 'Process Completion Requests',
          'icon': Icons.request_quote,
          'color': Colors.lightGreen,
          'description': 'Completion requests',
          'image': '✅'
        },
        {
          'title': 'Sale',
          'icon': Icons.money,
          'color': Colors.green,
          'description': 'Sales management',
          'image': '💰'
        },
      ];
    } else {
      sections = [
        {
          'title': 'Carpenter Requests',
          'icon': Icons.request_quote,
          'color': Colors.deepOrange,
          'description': 'Carpenter services',
          'image': '🔨'
        },
        {
          'title': 'Decoration Enquiry',
          'icon': Icons.request_quote,
          'color': Colors.brown,
          'description': 'Decoration requests',
          'image': '🎭'
        },
        {
          'title': 'Managers Orders',
          'icon': Icons.request_quote,
          'color': Colors.indigo,
          'description': 'Manager orders',
          'image': '👔'
        },
        {
          'title': 'Process Managers Orders',
          'icon': Icons.request_quote,
          'color': Colors.lime,
          'description': 'Process manager orders',
          'image': '🏭'
        },
        {
          'title': 'Process Completion Requests',
          'icon': Icons.request_quote,
          'color': Colors.lightGreen,
          'description': 'Completion requests',
          'image': '✅'
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Welcome, ${UserStatic.getUser()?.username}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
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
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = sections[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutBack,
                    child: _buildModernCard(section, context),
                  );
                },
                childCount: sections.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(Map<String, dynamic> section, BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateToPage(section['title']);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: section['color'].withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: Color(0x0F000000),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              navigateToPage(section['title']);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: section['color'].withOpacity(0.1),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced image/emoji container with beautiful gradients
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          section['color'].withOpacity(0.15),
                          section['color'].withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: section['color'].withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: section['color'].withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner glow effect
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.2,
                              colors: [
                                section['color'].withOpacity(0.12),
                                section['color'].withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                        // Emoji/Image with subtle shadow
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            section['image'] ?? '📱',
                            style: const TextStyle(
                              fontSize: 32,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Enhanced title with gradient text effect
                  Text(
                    section['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Enhanced description
                  if (section['description'] != null)
                    Text(
                      section['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  // Enhanced accent line with gradient
                  Container(
                    width: 35,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          section['color'].withOpacity(0.6),
                          section['color'].withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: section['color'].withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
