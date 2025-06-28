import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/pages/enquiry/create_enquiry_page.dart';
import 'package:madeira/app/pages/splash_screen.dart';
import 'package:madeira/app/pages/users/change_password.dart';
import 'package:madeira/app/services/firebase_messaging_service.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/admin_only_widget.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

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
                  // ListTile(
                  //   title: const Text('Copy FCM Token'),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   tileColor: Colors.blue.shade100,
                  //   onTap: () async {
                  //     Clipboard.setData(
                  //       ClipboardData(
                  //         text: FirebaseMessagingService.fcmToken ??
                  //             await FirebaseMessaging.instance.getToken() ??
                  //             '',
                  //       ),
                  //     );
                  //     context.showSnackBar('FCM Token copied to clipboard');
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                ],
              ),
              Column(
                children: [
                  if (_version.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Version $_version',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
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
