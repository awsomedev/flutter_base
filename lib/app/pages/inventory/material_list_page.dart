import 'package:flutter/material.dart';
import 'package:madeira/app/pages/inventory/create_material_page.dart';
import '../../models/material_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';

class MaterialListPage extends StatefulWidget {
  final int? categoryId;

  const MaterialListPage({
    Key? key,
    this.categoryId,
  }) : super(key: key);

  @override
  State<MaterialListPage> createState() => _MaterialListPageState();
}

class _MaterialListPageState extends State<MaterialListPage> {
  List<MaterialModel> materials = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    try {
      final materialList = await Services().getMaterials();
      if (mounted) {
        setState(() {
          materials = widget.categoryId != null
              ? materialList
                  .where((m) => m.category == widget.categoryId)
                  .toList()
              : materialList;
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
    print('materials: ${materials.length}');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Materials',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      ExpansionTile(
                        title: Text(
                          material.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Stock: ${material.stockAvailability} • Price: ₹${material.price}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateMaterialPage(
                                      material: material,
                                      categoryId: widget.categoryId,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  fetchMaterials();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Material'),
                                    content: Text(
                                      'Are you sure you want to delete ${material.name}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: AppColors.textSecondary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            await Services()
                                                .deleteMaterial(material.id);
                                            if (mounted) {
                                              Navigator.pop(context);
                                              fetchMaterials();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Material deleted successfully'),
                                                  backgroundColor:
                                                      AppColors.success,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Failed to delete material: $e'),
                                                backgroundColor:
                                                    AppColors.error,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Delete',
                                          style:
                                              TextStyle(color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(
                                    'Description', material.description),
                                _buildDetailRow('Color', material.colour),
                                _buildDetailRow('Quality', material.quality),
                                _buildDetailRow(
                                    'Durability', material.durability),
                                if (material.quantity != null)
                                  _buildDetailRow(
                                      'Quantity', material.quantity.toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMaterialPage(
                categoryId: widget.categoryId,
              ),
            ),
          );
          if (result == true) {
            fetchMaterials();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
