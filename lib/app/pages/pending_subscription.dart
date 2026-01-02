import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Subscription'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Payment'),
          onPressed: () {
            // TODO: Implement refresh payment logic here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refreshing payment...')),
            );
          },
        ),
      ),
    );
  }
}
