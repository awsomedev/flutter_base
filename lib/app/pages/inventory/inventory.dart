import 'package:flutter/material.dart';
import 'category_list_page.dart';
import 'product_category_list_page.dart';

class InventoryDashboardPage extends StatelessWidget {
  const InventoryDashboardPage({super.key});

  final List<Map<String, dynamic>> inventoryOptions = const [
    {
      'title': 'Materials',
      'icon': Icons.inventory_2_rounded,
      'color': Color(0xFF6366F1),
      'subtitle': 'Manage raw materials',
    },
    {
      'title': 'Category',
      'icon': Icons.category_rounded,
      'color': Color(0xFF8B5CF6),
      'subtitle': 'Material categories',
    },
    {
      'title': 'Product Categories',
      'icon': Icons.auto_awesome_motion_rounded,
      'color': Color(0xFFF59E0B),
      'subtitle': 'Manage collections',
    },
  ];

  Widget _buildModernCard(BuildContext context, Map<String, dynamic> option, int index) {
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
      child: GestureDetector(
        onTap: () {
          switch (option['title']) {
            case 'Category':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryListPage()),
              );
              break;
            case 'Product Categories':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCategoryListPage()),
              );
              break;
            case 'Materials':
              // This often needs a category, but for now we follow existing logic
              break;
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: (option['color'] as Color).withOpacity(0.08),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (option['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option['icon'],
                  size: 40,
                  color: option['color'],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                option['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option['subtitle'],
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF6366F1),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Inventory Management',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
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
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildModernCard(context, inventoryOptions[index], index),
                childCount: inventoryOptions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
