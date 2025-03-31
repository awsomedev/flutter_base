import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/pages/enquiry/create_enquiry_page.dart';
import 'package:madeira/app/pages/splash_screen.dart';
import 'package:madeira/app/pages/users/change_password.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/admin_only_widget.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Home'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.blue.shade100,
                    onTap: () {
                      context.pop();
                    },
                  ),
                  const SizedBox(height: 10),
                  if (AdminTracker.isAdmin)
                    Column(
                      children: [
                        ListTile(
                          title: const Text('Create Enuiry'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: Colors.blue.shade100,
                          onTap: () {
                            context.push(() => const CreateEnquiryPage());
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ListTile(
                    title: const Text('Change Password'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.blue.shade100,
                    onTap: () {
                      context.push(() => const ChangePasswordPage());
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.red.shade900,
                    onTap: () async {
                      bool? res = await ConfirmationDialog.show(
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                        context: context,
                      );
                      if (res == true) {
                        await Services().clearAuth();
                        context.pushAndRemoveAll(() => const SplashScreen());
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
