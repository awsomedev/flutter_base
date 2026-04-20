import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/models/decoration_enquiry_response.dart';
import 'package:madeira/app/pages/decorations/enquiey_view.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';

class DecorationEnquiriesPage extends StatefulWidget {
  const DecorationEnquiriesPage({Key? key}) : super(key: key);

  @override
  State<DecorationEnquiriesPage> createState() =>
      _DecorationEnquiriesPageState();
}

class _DecorationEnquiriesPageState extends State<DecorationEnquiriesPage> {
  late Future<DecorationEnquiryResponse> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = Services().fetchDecorationsEnquiries();
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = Services().fetchDecorationsEnquiries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
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
                'Decoration Requests',
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
          FutureBuilder<DecorationEnquiryResponse>(
            future: _requestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: CustomErrorWidget(
                    error: snapshot.error.toString(),
                    onRetry: _refreshRequests,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline_rounded, size: 64, color: const Color(0xFF6366F1).withOpacity(0.2)),
                        const SizedBox(height: 16),
                        const Text(
                          'No requests found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final requests = snapshot.data!.data;
              return SliverPadding(
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: _RequestCard(
                                request: requests[index],
                                onRequestAccepted: _refreshRequests,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: requests.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final DecorEnquiry request;
  final VoidCallback? onRequestAccepted;

  const _RequestCard({
    Key? key,
    required this.request,
    this.onRequestAccepted,
  }) : super(key: key);

  Future<void> _handleAccept(BuildContext context) async {
    final result = await ConfirmationDialog.show(
      context: context,
      title: 'Accept Request',
      message: 'Are you sure you want to accept this decoration request?',
      confirmText: 'ACCEPT',
      cancelText: 'CANCEL',
    );

    if (result == true) {
      try {
        await Services().acceptDecorationEnquiryRequest(request.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request accepted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnquiryViewPage(enquiryId: request.id),
            ),
          );
          onRequestAccepted?.call();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to accept request: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (request.status == 'requested') {
                _handleAccept(context);
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnquiryViewPage(enquiryId: request.id),
                ),
              );
              onRequestAccepted?.call();
            },
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.aboutEnquiry,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enquiry ID: #${request.id}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(request.status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (request.enquiryDescription != null) ...[
                    Text(
                      request.enquiryDescription!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: const Color(0xFF6366F1).withOpacity(0.7)),
                          const SizedBox(width: 6),
                          const Text(
                            'Active Decoration',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      if (request.status == 'requested')
                        ElevatedButton(
                          onPressed: () => _handleAccept(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'ACCEPT',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                          ),
                        )
                      else
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    Color bgColor;
    String label = status?.toUpperCase() ?? 'UNKNOWN';

    switch (status?.toLowerCase()) {
      case 'completed':
        color = const Color(0xFF10B981);
        bgColor = const Color(0xFFD1FAE5);
        break;
      case 'requested':
        color = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFEF3C7);
        break;
      case 'checking':
        color = const Color(0xFF6366F1);
        bgColor = const Color(0xFFE0E7FF);
        break;
      default:
        color = const Color(0xFF64748B);
        bgColor = const Color(0xFFF1F5F9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
