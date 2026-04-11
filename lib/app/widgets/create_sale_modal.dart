// lib/features/product/widgets/product_sale_modal.dart
import 'package:flutter/material.dart';

class ProductSaleModal {
  static Future<void> show({
    required BuildContext context,
    required String productName,
    required Function(Map<String, dynamic>) onSubmit,
    required int productId,
    required double productPrice,
  }) async {
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

    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * anim1.value),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 28),
                              SizedBox(width: 16),
                              Text(
                                'Initialize Sale Order',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                              ),
                            ],
                          ),
                        ),
                        
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('Product Information', Icons.inventory_2_rounded),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(productName, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 16)),
                                            Text('Base Price: ₹$productPrice', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                _buildSectionHeader('Sale Details', Icons.receipt_long_rounded),
                                Row(
                                  children: [
                                    Expanded(child: _buildTextField(quantityController, 'Quantity*', Icons.numbers, isNumber: true)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextField(additionalCostController, 'Addl. Cost', Icons.add_rounded, isNumber: true)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: deliveryStatus,
                                  decoration: _inputDecoration('Delivery Status*', Icons.local_shipping_rounded),
                                  items: const [
                                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                    DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                                    DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                                  ],
                                  onChanged: (value) => setState(() => deliveryStatus = value!),
                                ),
                                const SizedBox(height: 20),
                                const Text('Order Rating', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (i) => IconButton(
                                    icon: Icon(Icons.star_rounded, color: i < rating ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0), size: 36),
                                    onPressed: () => setState(() => rating = i + 1),
                                  )),
                                ),
                                const SizedBox(height: 24),
                                
                                _buildSectionHeader('Client Details', Icons.person_rounded),
                                _buildTextField(clientNameController, 'Full Name*', Icons.badge_outlined),
                                const SizedBox(height: 16),
                                _buildTextField(phoneController, 'Phone Number*', Icons.phone_outlined, isNumber: true),
                                const SizedBox(height: 16),
                                _buildTextField(whatsappController, 'WhatsApp Number', Icons.chat_outlined, isNumber: true),
                                const SizedBox(height: 16),
                                _buildTextField(addressController, 'Detailed Address*', Icons.location_on_outlined, maxLines: 2),
                              ],
                            ),
                          ),
                        ),

                        // Actions
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (quantityController.text.isEmpty || clientNameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Required fields missing"), backgroundColor: Color(0xFFEF4444)));
                                        return;
                                      }
                                      final saleData = {
                                        'product_name': productName,
                                        'product_id': productId,
                                        'quantity': int.parse(quantityController.text),
                                        'price': productPrice,
                                        'additional_cost': double.tryParse(additionalCostController.text) ?? 0.0,
                                        'delivery_status': deliveryStatus,
                                        'rating': rating,
                                        'client_name': clientNameController.text,
                                        'client_phone': phoneController.text,
                                        'client_whatsapp': whatsappController.text.isNotEmpty ? whatsappController.text : phoneController.text,
                                        'client_address': addressController.text,
                                      };
                                      Navigator.pop(context, saleData);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: const Text('Create Sale', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null) {
      onSubmit(result);
    }
  }

  static Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF475569), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  static Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: _inputDecoration(label, icon),
    );
  }

  static InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }
}
