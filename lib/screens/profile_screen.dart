// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/theme_provider.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userEmail = authProvider.user?.email ?? "No Email";
    final initialBalance = userProfileProvider.initialBalance ?? 0.0;
    
    final isDarkBlue = themeProvider.isDarkBlue;
    final backgroundColor = isDarkBlue ? AppColors.darkBlue : AppColors.background;
    final primaryColor = isDarkBlue ? AppColors.yellow : AppColors.primary;
    final textColor = isDarkBlue ? AppColors.white : AppColors.text;
    final cardColor = isDarkBlue ? AppColors.darkBlueAccent : Colors.white;
    final iconColor = isDarkBlue ? AppColors.yellow : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkBlue ? AppColors.yellow : Colors.white,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            }
          },
          tooltip: 'Back',
        ),
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(color: isDarkBlue ? AppColors.yellow : Colors.white),
        ),
        backgroundColor: isDarkBlue ? AppColors.darkBlue : AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(
              isDarkBlue ? Icons.light_mode : Icons.dark_mode,
              color: isDarkBlue ? AppColors.yellow : Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: isDarkBlue ? 'Switch to Light Theme' : 'Switch to Dark Blue Theme',
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withOpacity(0.3),
              child: Icon(Icons.person, size: 60, color: primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Initial Balance: \$${initialBalance.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                color: isDarkBlue ? AppColors.yellowAccent : AppColors.grey,
              ),
            ),
            SizedBox(height: 24),
            Card(
              color: cardColor,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.category, color: iconColor),
                    title: Text(
                      "Manage Categories",
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: textColor,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.categoryManagement);
                    },
                  ),
                  Divider(height: 1, color: isDarkBlue ? AppColors.darkBlue : Colors.grey.shade300),
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet, color: iconColor),
                    title: Text(
                      "Budgets",
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: textColor,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.budget);
                    },
                  ),
                  Divider(height: 1, color: isDarkBlue ? AppColors.darkBlue : Colors.grey.shade300),
                  ListTile(
                    leading: Icon(Icons.flag, color: iconColor),
                    title: Text(
                      "Goals",
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: textColor,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.goals);
                    },
                  ),
                  Divider(height: 1, color: isDarkBlue ? AppColors.darkBlue : Colors.grey.shade300),
                  ListTile(
                    leading: Icon(Icons.account_balance, color: iconColor),
                    title: Text(
                      "Update Initial Balance",
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: textColor,
                    ),
                    onTap: () => _showUpdateBalanceDialog(context, userProfileProvider),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDarkBlue ? AppColors.darkBlue : Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: Text("Logout", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateBalanceDialog(BuildContext context, UserProfileProvider userProfileProvider) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: userProfileProvider.initialBalance?.toStringAsFixed(2) ?? '0.00',
    );
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Update Initial Balance"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Initial Balance",
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter an amount";
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return "Please enter a valid amount";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() => isLoading = true);
                        final success = await userProfileProvider.updateInitialBalance(
                          double.parse(amountController.text),
                        );
                        setState(() => isLoading = false);

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Balance updated successfully'),
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${userProfileProvider.error ?? "Failed to update balance"}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
