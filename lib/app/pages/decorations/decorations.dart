import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/models/decorations_response_model.dart';
import 'package:madeira/app/pages/decorations/create_deacoration_enquiry.dart';
import 'package:madeira/app/pages/inventory/create_category_page.dart';
import '../../models/category_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';

class DecorationsPage extends StatefulWidget {
  const DecorationsPage({super.key});

  @override
  State<DecorationsPage> createState() => _DecorationsPageState();
}

class _DecorationsPageState extends State<DecorationsPage> {
  List<DecorationResponse> decorations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDecoration();
  }

  Future<void> fetchDecoration() async {
    try {
      final decorationList = await Services().fetchDecorations();
      if (mounted) {
        setState(() {
          decorations = decorationList;
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
          'Decoration',
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
                    itemCount: decorations.length,
                    itemBuilder: (context, index) {
                      final decoration = decorations[index];
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
                                    decoration.enquiryName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
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
                                              CreateDecorationEnquiryPage(
                                            decoration: decoration,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        fetchDecoration();
                                      }
                                    },
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
              builder: (context) => const CreateDecorationEnquiryPage(),
            ),
          );
          if (result == true) {
            fetchDecoration(); // Refresh the list
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
