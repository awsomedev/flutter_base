import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/decoration_enquiry_detail_response.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EnquiryViewPage extends StatefulWidget {
  final int enquiryId;

  const EnquiryViewPage({Key? key, required this.enquiryId}) : super(key: key);

  @override
  State<EnquiryViewPage> createState() => _EnquiryViewPageState();
}

class _EnquiryViewPageState extends State<EnquiryViewPage> {
  late Future<DecorationEnquiryDetailResponse> _requestDetailFuture;
  final _descriptionController = TextEditingController();
  final _constController = TextEditingController();
  final _daysController = TextEditingController();

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestDetailFuture = Services().getDecorEnquiryDetail(widget.enquiryId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updateEnquiryDetails(BuildContext context) async {
    // Validate all fields are filled
    bool hasEmptyFields = false;

    hasEmptyFields = _descriptionController.text.isEmpty ||
        _constController.text.isEmpty ||
        _daysController.text.isEmpty;

    if (hasEmptyFields) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    bool? isAccepted = await ConfirmationDialog.show(
        context: context, title: 'Do you want to submit', message: '');

    if (isAccepted != true) {
      return;
    }

    Map<String, dynamic> updateData = {
      "enquiry_description": _descriptionController.text,
      "completion_time": _daysController.text,
      "cost": _constController.text
    };

    try {
      await Services().updateEnquiryDetails(widget.enquiryId, updateData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dimensions updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update enquiry'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<DecorationEnquiryDetailResponse>(
        future: _requestDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _requestDetailFuture = Services().getDecorEnquiryDetail(widget.enquiryId);
                });
              },
            );
          }

          final request = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF6366F1),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Enquiry Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernProductSection(request.orderData),
                      const SizedBox(height: 24),
                      _buildModernEnquirySection(request.enquiryData),
                      const SizedBox(height: 32),
                      if (request.enquiryData.status == 'checking')
                        _buildUpdateButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _updateEnquiryDetails(context),
        icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
        label: const Text(
          'SUBMIT QUOTATION',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildModernProductSection(DecorationOrderData orderData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (orderData.referenceImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 250,
                      viewportFraction: 1.0,
                      autoPlay: orderData.referenceImage.length > 1,
                      onPageChanged: (index, reason) => setState(() => _currentImageIndex = index),
                    ),
                    items: orderData.referenceImage.map((image) {
                      return Image.network(
                        image.image.toImageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.broken_image_outlined, size: 48, color: Color(0xFFCBD5E1)),
                        ),
                      );
                    }).toList(),
                  ),
                  if (orderData.referenceImage.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: orderData.referenceImage.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(_currentImageIndex == entry.key ? 0.9 : 0.4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inventory_2_rounded, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'PRODUCT DETAILS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6366F1),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  orderData.productName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                ),
                if (orderData.productNameMal != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      orderData.productNameMal!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.auto_awesome_rounded, 'Finish', orderData.finish),
                const SizedBox(height: 24),
                const Text(
                  'Dimensions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildModernDimensionBadge('L', orderData.productLength)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildModernDimensionBadge('W', orderData.productWidth)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildModernDimensionBadge('H', orderData.productHeight)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Materials',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: orderData.materials.map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      m.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569)),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEnquirySection(DecorEnquiryData enquiryData) {
    if (_descriptionController.text.isEmpty) _descriptionController.text = enquiryData.enquiryDescription ?? '';
    // Note: Cost and completion time are double/int in model, but controllers need strings
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_center_rounded, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 12),
              Text(
                'ENQUIRY QUOTATION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B5CF6),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Client Request', enquiryData.aboutEnquiry),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          _buildModernInputField(
            controller: _descriptionController,
            label: 'Quotation Description',
            icon: Icons.notes_rounded,
            maxLines: 3,
            hint: 'Details about the proposed work...',
          ),
          Row(
            children: [
              Expanded(
                child: _buildModernInputField(
                  controller: _daysController,
                  label: 'Days Required',
                  icon: Icons.timer_rounded,
                  hint: '7',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernInputField(
                  controller: _constController,
                  label: 'Estimated Cost',
                  icon: Icons.payments_rounded,
                  hint: '5000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w400),
            prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildModernDimensionBadge(String label, double? value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text(
            '${value ?? 0} ft',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF334155), height: 1.5),
        ),
      ],
    );
  }
}
