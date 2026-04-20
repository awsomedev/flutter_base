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
      backgroundColor: const Color(0xFFF1F5F9), // Lighter, cleaner background
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = sections[index];
                  // Staggered animation entry effect
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 50)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: _buildModernCard(section, context),
                        ),
                      );
                    },
                  );
                },
                childCount: sections.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final user = UserStatic.getUser();
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Modern gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1), // Indigo
                    Color(0xFF8B5CF6), // Violet
                  ],
                ),
              ),
            ),
            // Decorative circles for extra "premium" feel
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -30,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.03),
              ),
            ),
            // Header content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.username ?? 'Guest User',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }


  Widget _buildModernCard(Map<String, dynamic> section, BuildContext context) {
    final Color color = section['color'] ?? const Color(0xFF6366F1);
    return GestureDetector(
      onTap: () => navigateToPage(section['title']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              offset: const Offset(0, 12),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Subtle background element
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon/Emoji Container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.12),
                            color.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          section['image'] ?? '📱',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      section['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      section['description'] ?? 'Manage details',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Action button lookalike
                    Container(
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ),
              // Hover/Tap effect overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => navigateToPage(section['title']),
                    splashColor: color.withOpacity(0.1),
                    highlightColor: color.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
