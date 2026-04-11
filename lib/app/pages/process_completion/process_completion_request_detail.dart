import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/process_completion_request_model.dart' as model;
import 'package:madeira/app/models/process_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProcessCompletionRequestDetail extends StatefulWidget {
  final int orderId;

  const ProcessCompletionRequestDetail({
    super.key,
    required this.orderId,
  });

  @override
  State<ProcessCompletionRequestDetail> createState() =>
      _ProcessCompletionRequestDetailState();
}

class _ProcessCompletionRequestDetailState
    extends State<ProcessCompletionRequestDetail> {
  late Future<model.ProcessCompletionRequestVerification> _requestFuture;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestFuture = Services().getProcessCompletionRequestVerification(widget.orderId);
  }

  Future<void> _handleAction(int processId, bool isApprove) async {
    final action = isApprove ? 'approve' : 'reject';
    try {
      bool? res = await ConfirmationDialog.show(
        title: "Confirmation",
        message: "Are you sure you want to $action this process?",
        context: context,
        confirmText: isApprove ? 'Approve' : 'Reject',
        cancelText: 'Cancel',
      );
      if (res == true) {
        if (isApprove) {
          await Services().acceptProcessVerification(processId);
        } else {
          await Services().rejectProcessVerification(processId);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Process $action' 'd successfully'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<model.ProcessCompletionRequestVerification>(
        future: _requestFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 16));
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _requestFuture = Services().getProcessCompletionRequestVerification(widget.orderId);
                });
              },
            );
          }

          final request = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 110.0,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF6366F1),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    request.orderData.productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                        ),
                      ),
                      if (request.orderData.images.isNotEmpty)
                        Opacity(
                          opacity: 0.6,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 110,
                              viewportFraction: 1.0,
                              autoPlay: request.orderData.images.length > 1,
                              onPageChanged: (index, _) => setState(() => _currentImageIndex = index),
                            ),
                            items: request.orderData.images.map((img) => Image.network(img.image.toImageUrl, fit: BoxFit.cover)).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(request.orderData),
                      const SizedBox(height: 24),
                      _buildProcessSection(request.process, request.processDetails),
                      const SizedBox(height: 24),
                      if (request.materials.isNotEmpty) ...[
                        _buildMaterialsSection(request.materials),
                        const SizedBox(height: 32),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: 'Reject',
                              onPressed: () => _handleAction(request.processDetails.id, false),
                              color: const Color(0xFFEF4444),
                              icon: Icons.close_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              label: 'Approve',
                              onPressed: () => _handleAction(request.processDetails.id, true),
                              color: const Color(0xFF10B981),
                              icon: Icons.check_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
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

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(model.ProcessCompletionRequestOrderData orderData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Product Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
              ),
              const Spacer(),
              _buildBadge(orderData.priority.toUpperCase(), const Color(0xFF6366F1)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            orderData.productName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            orderData.productDescription,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), thickness: 2),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricItem('Length', '${orderData.productLength}', 'in'),
              _buildMetricItem('Width', '${orderData.productWidth}', 'in'),
              _buildMetricItem('Height', '${orderData.productHeight}', 'in'),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Finish', orderData.finish),
          _buildDetailRow('Event', orderData.event),
          _buildDetailRow('Estimated Delivery', orderData.estimatedDeliveryDate ?? 'Not set'),
        ],
      ),
    );
  }

  Widget _buildProcessSection(Process process, model.ProcessCompletionRequestDetails details) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_suggest_rounded, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Process Info',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
              ),
              const Spacer(),
              _buildBadge(details.processStatus.toUpperCase(), details.overDue ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            process.name ?? 'Unknown Process',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          if (process.description != null) ...[
            const SizedBox(height: 8),
            Text(process.description!, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
          ],
          const SizedBox(height: 24),
          _buildPriceCard(details.totalPrice, details.workersSalary, details.materialPrice),
          const SizedBox(height: 20),
          _buildDetailRow('Expected Completion', details.expectedCompletionDate ?? 'Not set'),
        ],
      ),
    );
  }

  Widget _buildPriceCard(double total, double salary, double material) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Cost', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              Text('₹$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Expanded(child: _buildSubPrice('Salary', '₹$salary')),
              Container(width: 1, height: 30, color: const Color(0xFFF1F5F9)),
              Expanded(child: _buildSubPrice('Materials', '₹$material')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubPrice(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildMaterialsSection(List<model.MaterialUsed> materials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'MATERIALS USED',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1),
          ),
        ),
        ...materials.map((m) => _buildMaterialItemCard(m)).toList(),
      ],
    );
  }

  Widget _buildMaterialItemCard(model.MaterialUsed material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.material.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                Text('Qty: ${material.quantity}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${material.totalPrice}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              Text('₹${material.materialPrice}/unit', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
    );
  }
}
