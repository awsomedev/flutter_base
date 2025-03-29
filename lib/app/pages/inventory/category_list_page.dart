import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/pages/inventory/create_category_page.dart';
import '../../models/category_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';
import 'material_list_page.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final categoryList = await Services().getCategories();
      if (mounted) {
        setState(() {
          categories = categoryList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Column(
                        children: [
                          Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            color: AppColors.surface,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    category.description,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateCategoryPage(
                                            category: category,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        fetchCategories();
                                      }
                                    },
                                  ),
                                ),
                                const Divider(height: 1),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      context.push(() => MaterialListPage(
                                            categoryId: category.id,
                                            categoryName: category.name,
                                          ));
                                    },
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    label: const Text(
                                      'Material',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Add spacing between cards
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCategoryPage(),
            ),
          );
          if (result == true) {
            fetchCategories(); // Refresh the list
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
