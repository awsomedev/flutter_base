import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/models/process_completion_request_model.dart';
import 'package:madeira/app/pages/process_completion/process_completion_request_detail.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';

class ProcessCompletionRequestList extends StatefulWidget {
  const ProcessCompletionRequestList({
    super.key,
  });

  @override
  State<ProcessCompletionRequestList> createState() =>
      _ProcessCompletionRequestListState();
}

class _ProcessCompletionRequestListState
    extends State<ProcessCompletionRequestList> {
  late Future<List<ProcessCompletionRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = Services().getProcessCompletionRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<List<ProcessCompletionRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 16));
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _requestsFuture = Services().getProcessCompletionRequests();
                });
              },
            );
          }

          final requests = snapshot.data!;

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
                  title: const Text(
                    'Completion Requests',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
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
              if (requests.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No completion requests found',
                      style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildRequestCard(requests[index], index);
                      },
                      childCount: requests.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(ProcessCompletionRequest request, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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
        child: InkWell(
          onTap: () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProcessCompletionRequestDetail(orderId: request.id!),
              ),
            );
            if (res == true) {
              setState(() {
                _requestsFuture = Services().getProcessCompletionRequests();
              });
            }
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBadge(request.priority?.toUpperCase() ?? 'NORMAL', const Color(0xFF6366F1)),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  request.productName ?? 'Unknown Product',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  request.productDescription ?? 'No description available',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoItem(Icons.straighten_rounded, 'L:${request.productLength}″ W:${request.productWidth}″ H:${request.productHeight}″'),
                    const SizedBox(width: 20),
                    _buildInfoItem(Icons.auto_awesome_rounded, request.finish ?? 'Standard'),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(Icons.calendar_today_rounded, 'Delivery: ${request.estimatedDeliveryDate ?? "TBD"}', isHighlight: true),
              ],
            ),
          ),
        ),
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

  Widget _buildInfoItem(IconData icon, String text, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isHighlight ? const Color(0xFF6366F1) : const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
            color: isHighlight ? const Color(0xFF1E293B) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
