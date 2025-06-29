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
      appBar: AppBar(title: const Text('Sale Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.productName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _infoRow('Price', '₹${sale.price}'),
                _infoRow('Quantity', '${sale.quantity}'),
                _infoRow('Additional Cost', '₹${sale.additionalCost}'),
                _infoRow('Total', '₹${sale.totalPrice}'),
                _infoRow('Created By', sale.createdBy),
                _infoRow('Date', _formatDate(sale.createdAt)),
                const SizedBox(height: 24),
                const Text(
                  'Client Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _infoRow('Name', sale.clientName),
                _infoRow('Phone', sale.clientPhone),
                _infoRow('WhatsApp', sale.clientWhatsapp),
                _infoRow('Address', sale.clientAddress),
                const SizedBox(height: 16),
                const Text(
                  'Delivery Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                  items: statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child:
                          Text(status[0].toUpperCase() + status.substring(1)),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rating',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        Icons.star,
                        color: i < editableRating
                            ? Colors.amber
                            : Colors.grey.shade300,
                        size: 26,
                      ),
                      onPressed: isReadOnly
                          ? null
                          : () {
                              setState(() {
                                editableRating = i + 1;
                              });
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (!isReadOnly)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveStatus,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (isReadOnly)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'This sale is delivered and cannot be edited.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
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
