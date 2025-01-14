import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/pages/inventory/category_list_page.dart';
import 'package:madeira/app/pages/process/process_list_page.dart';
import 'package:madeira/app/pages/users/user_list_page.dart';
import 'inventory/inventory.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> sections = [
    {'title': 'Enquiry', 'icon': Icons.question_answer},
    {'title': 'Orders', 'icon': Icons.shopping_cart},
    {'title': 'Inventory', 'icon': Icons.inventory},
    {'title': 'Users', 'icon': Icons.people},
    {'title': 'Process', 'icon': Icons.production_quantity_limits},
  ];

  void navigateToPage(String page) {
    switch (page) {
      case 'Inventory':
        context.push(() => const CategoryListPage());
        break;
      case 'Users':
        context.push(() => const UserListPage());
        break;
      case 'Process':
        context.push(() => const ProcessListPage());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return GestureDetector(
            onTap: () {
              navigateToPage(section['title']);
            },
            child: Card(
              elevation: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    section['icon'],
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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