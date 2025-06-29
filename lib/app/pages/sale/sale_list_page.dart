import 'package:flutter/material.dart';
import 'package:madeira/app/pages/sale/sale_order.dart';
import 'package:madeira/app/services/services.dart';
import 'sale_detail_page.dart'; // Make sure this file exists

class SaleListPage extends StatefulWidget {
  @override
  _SaleListPageState createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _salesFuture = Services().fetchSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales List'),
      ),
      body: FutureBuilder<List<Sale>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading sales'));
          }
          final sales = snapshot.data ?? [];
          if (sales.isEmpty) {
            return const Center(child: Text('No sales found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              final isDelivered =
                  sale.deliveryStatus.toLowerCase() == 'delivered';

              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SaleDetailPage(
                        sale: sale,
                        isReadOnly: isDelivered, // Pass read-only mode
                      ),
                    ),
                  );

                  if (result != null && mounted) {
                    _loadSales(); // 🔁 Refresh the list when coming back
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDelivered ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Price: ₹${double.tryParse(sale.price)?.toStringAsFixed(2) ?? sale.price}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Quantity: ${sale.quantity}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Total Price: ₹${double.tryParse(sale.totalPrice)?.toStringAsFixed(2) ?? sale.totalPrice}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Client: ${sale.clientName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Delivery Status: ${sale.deliveryStatus}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              Icons.star,
                              size: 18,
                              color: starIndex < sale.rating
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
