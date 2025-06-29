import 'package:flutter/material.dart';
import 'package:madeira/app/pages/inventory/create_product_page.dart';
import '../../models/product_model.dart';
import '../../services/services.dart';
import '../../app_essentials/colors.dart';
import '../../widgets/create_sale_modal.dart';

class ProductListPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductListPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final productList = await Services().getProducts();
      if (mounted) {
        setState(() {
          products = productList
              .where((p) => p.categoryId == widget.categoryId)
              .toList();
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
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: AppColors.textPrimary),
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
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final stockAvailability = StockAvailability.fromValue(
                    product.stockAvailability ?? 'in_stock');
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
                          product.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Stock: ${stockAvailability.displayName} • Price: ₹${product.price}',
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
                                    builder: (context) => CreateProductPage(
                                      product: product,
                                      categoryId: widget.categoryId,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  fetchProducts();
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
                                    title: const Text('Delete Product'),
                                    content: Text(
                                      'Are you sure you want to delete ${product.name}?',
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
                                                .deleteProduct(product.id);
                                            if (mounted) {
                                              Navigator.pop(context);
                                              fetchProducts();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Product deleted successfully'),
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
                                                    'Failed to delete product: $e'),
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
                                    'Description', product.description ?? ''),
                                _buildDetailRow('Color', product.colour ?? ''),
                                _buildDetailRow(
                                    'Quality', product.quality ?? ''),
                                _buildDetailRow(
                                    'Durability', product.durability ?? ''),
                                _buildDetailRow('Stock Status',
                                    stockAvailability.displayName),
                                if (product.quantity != null)
                                  _buildDetailRow(
                                      'Quantity', product.quantity.toString()),
                                _buildDetailRow(
                                    'MRP in GST', '₹${product.mrpInGst}'),
                                if (product.images.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Images:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 300,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: product.images.length,
                                      itemBuilder: (context, imageIndex) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              product.images[imageIndex].image,
                                              height: 650,
                                              width: 335,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    label: const Text('Create Sale'),
                                    onPressed: () {
                                      ProductSaleModal.show(
                                        context: context,
                                        productName:
                                            product.name ?? 'Unknown Product',
                                        productId: product.id,
                                        productPrice: product.price,
                                        onSubmit: (saleData) async {
                                          try {
                                            await Services()
                                                .CreateSaleOrder(saleData);
                                          } catch (e) {
                                            print("API ERROR: $e");
                                          }
                                        },
                                      );
                                      if (mounted) {
                                        fetchProducts();
                                      }
                                    },
                                  ),
                                ),
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
              builder: (context) => CreateProductPage(
                categoryId: widget.categoryId,
              ),
            ),
          );
          if (result == true) {
            fetchProducts();
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
