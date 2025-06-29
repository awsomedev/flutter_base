// lib/features/product/widgets/product_sale_modal.dart
import 'package:flutter/material.dart';

class ProductSaleModal {
  static void show({
    required BuildContext context,
    required String productName,
    required Function(Map<String, dynamic>) onSubmit,
    required int productId,
    required double productPrice,
  }) {
    // Controllers for all form fields
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController additionalCostController =
        TextEditingController();
    final TextEditingController clientNameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController whatsappController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    String deliveryStatus = 'pending';
    int rating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Create Sale"),
              scrollable: true,
              content: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.90, // 85% of screen width
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Information Section
                      ListTile(
                        leading:
                            const Icon(Icons.shopping_bag, color: Colors.blue),
                        title: const Text("Product:"),
                        subtitle: Text(
                          productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),

                      // Sale Details Section
                      const Text("Sale Details",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Quantity*",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: additionalCostController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Additional Cost",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: deliveryStatus,
                        decoration: const InputDecoration(
                          labelText: "Delivery Status*",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.delivery_dining),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'shipped', child: Text('Shipped')),
                          DropdownMenuItem(
                              value: 'delivered', child: Text('Delivered')),
                          DropdownMenuItem(
                              value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            deliveryStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              icon: Icon(
                                Icons.star,
                                color: i <= rating ? Colors.amber : Colors.grey,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  rating = i;
                                });
                              },
                            ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Client Details Section
                      const Text("Client Details",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: clientNameController,
                        decoration: const InputDecoration(
                          labelText: "Client Name*",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone Number*",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: whatsappController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "WhatsApp Number",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Address*",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child:
                      const Text("CANCEL", style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("CREATE SALE"),
                  onPressed: () {
                    // Validate required fields
                    if (quantityController.text.isEmpty ||
                        clientNameController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all required fields (*)"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Prepare sale data
                    final saleData = {
                      'product_name': productName,
                      'product_id': productId,
                      'quantity': int.parse(quantityController.text),
                      'price': productPrice,
                      'additional_cost':
                          additionalCostController.text.trim().isEmpty
                              ? 0.0
                              : double.tryParse(
                                      additionalCostController.text.trim()) ??
                                  0.0,
                      'delivery_status': deliveryStatus,
                      'rating': rating,
                      'client_name': clientNameController.text,
                      'client_phone': phoneController.text,
                      'client_whatsapp': whatsappController.text.isNotEmpty
                          ? whatsappController.text
                          : phoneController.text,
                      'client_address': addressController.text,
                    };
                    onSubmit(saleData); // Call the callback function
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
