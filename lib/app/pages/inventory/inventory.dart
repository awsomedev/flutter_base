import 'package:flutter/material.dart';
import 'category_list_page.dart';
import 'product_category_list_page.dart';

class InventoryDashboardPage extends StatelessWidget {
  const InventoryDashboardPage({super.key});

  final List<Map<String, dynamic>> inventoryOptions = const [
    {'title': 'Materials', 'icon': Icons.inventory_2},
    {'title': 'Category', 'icon': Icons.category},
    {'title': 'Product Categories', 'icon': Icons.category_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: inventoryOptions.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: GestureDetector(
              onTap: () {
                switch (inventoryOptions[index]['title']) {
                  case 'Category':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryListPage(),
                      ),
                    );
                    break;
                  case 'Product Categories':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductCategoryListPage(),
                      ),
                    );
                    break;
                  case 'Materials':
                    // Navigate to materials page
                    break;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    inventoryOptions[index]['icon'],
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inventoryOptions[index]['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
