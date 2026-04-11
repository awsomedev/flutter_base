import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/models/user_static.dart';
import 'package:madeira/app/pages/enquiry/create_enquiry_page.dart';
import 'package:madeira/app/pages/splash_screen.dart';
import 'package:madeira/app/pages/users/change_password.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/widgets/admin_only_widget.dart';
import 'package:madeira/app/widgets/confirmation_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? tileColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF6366F1).withOpacity(0.1),
          highlightColor: const Color(0xFF6366F1).withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              color: tileColor ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: tileColor != null ? Colors.transparent : const Color(0xFFF1F5F9),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(0xFF6366F1)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: const Color(0xFF94A3B8).withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserStatic.getUser();
    
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.username ?? 'User Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AdminTracker.isAdmin ? 'Administrator' : (AdminTracker.isEnqTaker ? 'Enquiry Taker' : 'Staff Member'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Drawer Items using Expanded with scroll view
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () => context.pop(),
                ),
                if (AdminTracker.isAdmin) ...[
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    icon: Icons.add_comment_rounded,
                    title: 'Create Enquiry',
                    iconColor: Colors.teal,
                    onTap: () {
                      context.pop();
                      context.push(() => const CreateEnquiryPage());
                    },
                  ),
                ],
                const SizedBox(height: 8),
                _buildDrawerItem(
                  icon: Icons.vpn_key_rounded,
                  title: 'Change Password',
                  iconColor: Colors.orange,
                  onTap: () {
                    context.pop();
                    context.push(() => const ChangePasswordPage());
                  },
                ),
              ],
            ),
          ),
          
          // Bottom Section
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    iconColor: const Color(0xFFEF4444),
                    textColor: const Color(0xFFEF4444),
                    tileColor: const Color(0xFFFEF2F2),
                    onTap: () async {
                      bool? res = await ConfirmationDialog.show(
                        title: 'Logout',
                        message: 'Are you sure you want to logout securely?',
                        context: context,
                      );
                      if (res == true) {
                        await Services().clearAuth();
                        context.pushAndRemoveAll(() => const SplashScreen());
                      }
                    },
                  ),
                  if (_version.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Version $_version',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
