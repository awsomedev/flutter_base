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
      appBar: AppBar(
        title: const Text('Requests'),
      ),
      body: SafeArea(
        child: FutureBuilder<DecorationEnquiryResponse>(
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

            if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Center(
                child: Text(
                  'No requests found',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final requests = snapshot.data!.data;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                return _RequestCard(
                  request: request,
                  onRequestAccepted: _refreshRequests,
                );
              },
            );
          },
        ),
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
      message: 'Are you sure you want to accept this request?',
      confirmText: 'Accept',
      cancelText: 'Cancel',
    );

    if (result == true) {
      try {
        await Services().acceptDecorationEnquiryRequest(request.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request accepted successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        onRequestAccepted?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to accept request: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (request.status == 'requested') {
            _handleAccept(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnquiryViewPage(enquiryId: request.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.aboutEnquiry,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.toUpperCase() ?? '',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.enquiryDescription ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            if (request.status == 'requested') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleAccept(context),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return CupertinoColors.systemGreen;
      case 'requested':
        return CupertinoColors.systemOrange;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}
