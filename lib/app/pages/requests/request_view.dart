import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/extensions/string_extension.dart';
import 'package:madeira/app/models/request_detail_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RequestViewPage extends StatefulWidget {
  final int orderId;

  const RequestViewPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<RequestViewPage> createState() => _RequestViewPageState();
}

class _RequestViewPageState extends State<RequestViewPage> {
  late Future<RequestDetail> _requestDetailFuture;
  final Map<int, Map<String, TextEditingController>> _dimensionControllers = {};
  final Map<int, String> _dimentionType = {};
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestDetailFuture = Services().getRequestDetail(widget.orderId);
  }

  @override
  void dispose() {
    for (var controllers in _dimensionControllers.values) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }

  Future<void> _updateDimensions(
      BuildContext context, List<MaterialWithEnquiry> materials) async {
    bool hasEmptyFields = false;
    String emptyFieldMaterial = '';

    for (var material in materials) {
      final controllers = _dimensionControllers[material.id];
      if (controllers == null) continue;
      final type = _dimentionType[material.id];

      if (type == 'round_log' &&
          (controllers['length']!.text.isEmpty ||
              controllers['gridth']!.text.isEmpty)) {
        hasEmptyFields = true;
        emptyFieldMaterial = material.name;
        break;
      }

      if (type == 'rectangular_wood' &&
          (controllers['length']!.text.isEmpty ||
              controllers['width']!.text.isEmpty ||
              controllers['thickness']!.text.isEmpty ||
              controllers['no_of_pieces']!.text.isEmpty)) {
        hasEmptyFields = true;
        emptyFieldMaterial = material.name;
        break;
      }
    }

    if (hasEmptyFields) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all dimensions for $emptyFieldMaterial'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    bool? isAccepted = await ConfirmationDialog.show(
        context: context,
        title: 'Update Dimensions',
        message: 'Are you sure you want to update these dimensions?');

    if (isAccepted != true) return;

    final List<Map<String, dynamic>> updateData = materials.map((material) {
      final controllers = _dimensionControllers[material.id]!;
      return {
        'order_id': widget.orderId,
        'material_id': material.id,
        'type': _dimentionType[material.id],
        'material_length': double.parse(controllers['length']!.text),
        'material_width': double.tryParse(controllers['width']!.text) ?? 0,
        'material_gridth': double.tryParse(controllers['gridth']!.text) ?? 0,
        'material_no_of_pieces':
            double.tryParse(controllers['no_of_pieces']!.text) ?? 0,
        'material_thickness':
            double.tryParse(controllers['thickness']!.text) ?? 0,
      };
    }).toList();

    try {
      await Services().updateRequestDimensions(updateData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dimensions updated successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
          ),
        );
        setState(() {
          _requestDetailFuture = Services().getRequestDetail(widget.orderId);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleFinishRequest(BuildContext context) async {
    bool? isAccepted = await ConfirmationDialog.show(
      context: context,
      title: 'Finish Request',
      message: 'Are you sure you want to finish this request? This action cannot be undone.',
      confirmText: 'Finish',
      cancelText: 'Cancel',
    );

    if (isAccepted != true) return;

    try {
      await Services().finishRequest(widget.orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request finished successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
          ),
        );
        setState(() {
          _requestDetailFuture = Services().getRequestDetail(widget.orderId);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to finish: ${e.toString()}'),
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
      body: FutureBuilder<RequestDetail>(
        future: _requestDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 16));
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _requestDetailFuture = Services().getRequestDetail(widget.orderId);
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
                    request.productName ?? 'Request Details',
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
                      if (request.images.isNotEmpty)
                        Opacity(
                          opacity: 0.6,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 110,
                              viewportFraction: 1.0,
                              autoPlay: request.images.length > 1,
                              onPageChanged: (index, _) => setState(() => _currentImageIndex = index),
                            ),
                            items: request.images.map((img) => Image.network(img.image.toImageUrl, fit: BoxFit.cover)).toList(),
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
                      _buildInfoSection(request),
                      const SizedBox(height: 24),
                      _buildMaterialsSection(request.materials, request.status == 'completed'),
                      const SizedBox(height: 32),
                      if (request.status != 'completed') ...[
                        _buildActionButton(
                          label: 'Update Dimensions',
                          onPressed: () => _updateDimensions(context, request.materials),
                          color: const Color(0xFF6366F1),
                          icon: Icons.straighten_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          label: 'Finish Request',
                          onPressed: () => _handleFinishRequest(context),
                          color: const Color(0xFF10B981),
                          icon: Icons.check_circle_rounded,
                        ),
                      ],
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
      width: double.infinity,
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
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
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

  Widget _buildInfoSection(RequestDetail request) {
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
              const Icon(Icons.info_outline_rounded, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _buildBadge(request.priority?.toUpperCase() ?? 'NORMAL', const Color(0xFF6366F1)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            request.productName ?? 'Unnamed Product',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          if (request.productNameMal != null)
            Text(
              request.productNameMal!,
              style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          const SizedBox(height: 20),
          _buildInfoBox(request.productDescription, request.productDescriptionMal),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), thickness: 2),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricItem('Length', '${request.productLength ?? 0}', 'ft'),
              _buildMetricItem('Width', '${request.productWidth ?? 0}', 'ft'),
              _buildMetricItem('Height', '${request.productHeight ?? 0}', 'ft'),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Finish', request.finish),
          _buildDetailRow('Event', request.event),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String? eng, String? mal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eng ?? 'No description',
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
          ),
          if (mal != null) ...[
            const SizedBox(height: 6),
            Text(mal, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
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

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
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

  Widget _buildMaterialsSection(List<MaterialWithEnquiry> materials, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'MATERIALS & DIMENSIONS',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1),
          ),
        ),
        ...materials.asMap().entries.map((entry) => _buildMaterialCard(entry.value, entry.key, isCompleted)).toList(),
      ],
    );
  }

  Widget _buildMaterialCard(MaterialWithEnquiry material, int index, bool isCompleted) {
    if (!_dimensionControllers.containsKey(material.id)) {
      _dimensionControllers[material.id] = {
        'length': TextEditingController(text: material.enquiryData.materialLength?.toString() ?? ''),
        'width': TextEditingController(text: material.enquiryData.materialWidth?.toString() ?? ''),
        'thickness': TextEditingController(text: material.enquiryData.materialHeight?.toString() ?? ''),
        'no_of_pieces': TextEditingController(text: ''),
        'gridth': TextEditingController(text: ''),
      };
      _dimentionType[material.id] = 'round_log';
    }

    final controllers = _dimensionControllers[material.id]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Text(
            material.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          if (material.nameMal != null)
            Text(material.nameMal, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 16),
          _buildInfoBox(material.description, material.descriptionMal),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _dimentionType[material.id],
            decoration: InputDecoration(
              labelText: 'Dimension Type',
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['round_log', 'rectangular_wood']
                .map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))))
                .toList(),
            onChanged: isCompleted ? null : (v) => setState(() => _dimentionType[material.id] = v!),
          ),
          const SizedBox(height: 20),
          if (_dimentionType[material.id] == 'round_log')
            Row(
              children: [
                Expanded(child: _buildInput('Length', controllers['length']!, isCompleted, 'ft')),
                const SizedBox(width: 12),
                Expanded(child: _buildInput('Gridth', controllers['gridth']!, isCompleted, 'in')),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInput('Length', controllers['length']!, isCompleted, 'ft')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput('Width', controllers['width']!, isCompleted, 'in')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInput('Thickness', controllers['thickness']!, isCompleted, 'in')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput('Pieces', controllers['no_of_pieces']!, isCompleted, 'pcs')),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, bool readOnly, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: '0.0',
              suffixText: unit,
              suffixStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
            ),
          ),
        ),
      ],
    );
  }
}
