import 'package:flutter/cupertino.dart';
import 'package:madeira/app/app_essentials/colors.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const CustomErrorWidget({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $error',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
