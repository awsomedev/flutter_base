import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/pages/enquiry/enquiry_page.dart';
import 'package:madeira/app/pages/inventory/category_list_page.dart';
import 'package:madeira/app/pages/orders/order_list_page.dart';
import 'package:madeira/app/pages/process/process_list_page.dart';
import 'package:madeira/app/pages/process_completion/process_completion_request_list.dart';
import 'package:madeira/app/pages/process_manager/process_manager_order_list.dart';
import 'package:madeira/app/pages/requests/request_list.dart';
import 'package:madeira/app/pages/users/user_list_page.dart';

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
    {'title': 'Carpenter Requests', 'icon': Icons.request_quote},
    {'title': 'Managers Orders', 'icon': Icons.request_quote},
    {'title': 'Process Managers Orders', 'icon': Icons.request_quote},
    {'title': 'Process Completion Requests', 'icon': Icons.request_quote},
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
      case 'Enquiry':
        context.push(() => const EnquiryPage());
        break;
      case 'Orders':
        context.push(() => const OrderListPage());
        break;
      case 'Carpenter Requests':
        context.push(() => const RequestListPage());
        break;
      case 'Managers Orders':
        context.push(() => const OrderListPage(
              managerId: 2,
            ));
        break;
      case 'Process Managers Orders':
        context.push(() => const ProcessManagerOrderList(
              processManagerId: 8,
            ));
        break;
      case 'Process Completion Requests':
        context.push(() => const ProcessCompletionRequestList());
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
              child: Padding(
                padding: const EdgeInsets.all(4.0),
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
