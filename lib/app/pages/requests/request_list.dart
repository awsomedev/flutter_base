import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/models/carpenter_request_model.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/error_widget.dart';
import 'package:madeira/app/widgets/loading_widget.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:madeira/app/pages/requests/request_view.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({Key? key}) : super(key: key);

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  late Future<CarpenterRequestResponse> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = Services().getCarpenterRequests();
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = Services().getCarpenterRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Carpenter Requests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<CarpenterRequestResponse>(
          future: _requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }

            if (snapshot.hasError) {
              return CustomErrorWidget(
                error: snapshot.error.toString(),
                onRetry: _refreshRequests,
              );
            }

            if (!snapshot.hasData || snapshot.data!.orderData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No requests found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New requests will appear here',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            final requests = snapshot.data!.orderData;
            return RefreshIndicator(
              color: const Color(0xFF667eea),
              onRefresh: () async {
                _refreshRequests();
                await _requestsFuture;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: requests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _RequestCard(
                    request: request,
                    onRequestAccepted: _refreshRequests,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final CarpenterRequest request;
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
      message: 'Are you sure you want to accept this request?',
      confirmText: 'Accept',
      cancelText: 'Cancel',
    );

    if (result == true) {
      try {
        await Services().acceptCarpenterRequest(request.orderId!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Request accepted successfully'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        onRequestAccepted?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Failed to accept request: ${e.toString()}'),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(request.status).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(request.status).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RequestViewPage(orderId: request.orderId!),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                            request.productName ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (request.productNameMal != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              request.productNameMal!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(request.status),
                            _getStatusColor(request.status).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(request.status)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(request.status),
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(request.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.productDescription ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                      ),
                      if (request.productDescriptionMal != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          request.productDescriptionMal!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (request.status == 'requested') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleAccept(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Accept Request',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'requested':
        return const Color(0xFFF59E0B);
      case 'accepted':
        return const Color(0xFF3B82F6);
      case 'in_progress':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'requested':
        return Icons.pending;
      case 'accepted':
        return Icons.thumb_up;
      case 'in_progress':
        return Icons.sync;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'requested':
        return 'PENDING';
      case 'completed':
        return 'DONE';
      case 'accepted':
        return 'ACCEPTED';
      case 'in_progress':
        return 'IN PROGRESS';
      default:
        return status?.toUpperCase() ?? 'UNKNOWN';
    }
  }
}
