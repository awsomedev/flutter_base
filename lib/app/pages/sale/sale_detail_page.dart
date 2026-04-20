import 'package:flutter/material.dart';
import 'package:madeira/app/pages/sale/sale_order.dart';
import 'package:madeira/app/services/services.dart';

class SaleDetailPage extends StatefulWidget {
  final Sale sale;
  final bool isReadOnly;

  const SaleDetailPage({
    Key? key,
    required this.sale,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  late String selectedStatus;
  late int editableRating;
  late bool isReadOnly;

  final List<String> statusOptions = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.sale.deliveryStatus;
    editableRating = widget.sale.rating;
    isReadOnly = widget.isReadOnly;
  }

  Future<void> _saveStatus() async {
    try {
      await Services().updateSaleStatusAndRating(
        id: widget.sale.id,
        status: selectedStatus,
        rating: editableRating,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );

      Navigator.pop(context, {
        'status': selectedStatus,
        'rating': editableRating,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 110.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              title: const Text(
                'Sale Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: 'Product Information',
                        icon: Icons.shopping_bag_rounded,
                        children: [
                          Text(
                            sale.productName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Unit Price', '₹${sale.price}'),
                          _buildDetailRow('Quantity', '${sale.quantity} Units'),
                          _buildDetailRow('Additional Cost', '₹${sale.additionalCost}'),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          _buildDetailRow('Total Price', '₹${sale.totalPrice}', isBold: true),
                          _buildDetailRow('Created By', sale.createdBy),
                          _buildDetailRow('Order Date', _formatDate(sale.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Client Details',
                        icon: Icons.person_rounded,
                        children: [
                          _buildDetailRow('Full Name', sale.clientName),
                          _buildDetailRow('Phone', sale.clientPhone, icon: Icons.phone_rounded),
                          _buildDetailRow('WhatsApp', sale.clientWhatsapp, icon: Icons.chat_rounded),
                          _buildDetailRow('Address', sale.clientAddress, icon: Icons.location_on_rounded),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Status & Feedback',
                        icon: Icons.track_changes_rounded,
                        children: [
                          const Text(
                            'Delivery Status',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            onChanged: isReadOnly
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => selectedStatus = value);
                                    }
                                  },
                            items: statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status[0].toUpperCase() + status.substring(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              );
                            }).toList(),
                            decoration: _inputDecoration('Status', Icons.local_shipping_rounded),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Customer Rating',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (i) => IconButton(
                                icon: Icon(
                                  Icons.star_rounded,
                                  color: i < editableRating ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                                  size: 32,
                                ),
                                onPressed: isReadOnly
                                    ? null
                                    : () {
                                        setState(() => editableRating = i + 1);
                                      },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (!isReadOnly)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _saveStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                          ),
                        ),
                      if (isReadOnly)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                              SizedBox(width: 8),
                              Text('This sale is delivered and read-only.', style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w800, fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), offset: const Offset(0, 8), blurRadius: 24),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF6366F1)),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF6366F1), letterSpacing: 0.5)),
              ],
            ),
            const Divider(height: 32, color: Color(0xFFF1F5F9)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 110,
            child: Text('$label:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                color: isBold ? const Color(0xFF6366F1) : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
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


  String _formatDate(dynamic rawDate) {
    try {
      DateTime dateTime =
          rawDate is DateTime ? rawDate : DateTime.parse(rawDate.toString());
      return "${dateTime.day.toString().padLeft(2, '0')}-"
          "${dateTime.month.toString().padLeft(2, '0')}-"
          "${dateTime.year}";
    } catch (e) {
      return rawDate.toString();
    }
  }
}
