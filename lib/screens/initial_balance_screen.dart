import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/user_profile_provider.dart';
import '../routes/app_routes.dart';

class InitialBalanceScreen extends StatefulWidget {
  static const String routeName = '/initialBalance';

  const InitialBalanceScreen({super.key});

  @override
  State<InitialBalanceScreen> createState() => _InitialBalanceScreenState();
}

class _InitialBalanceScreenState extends State<InitialBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                "Welcome to Finance Manager!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Enter your initial balance to get started",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Initial Balance",
                    hintText: "Enter your starting amount",
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter an amount";
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return "Please enter a valid amount";
                    }
                    if (amount < 0) {
                      return "Amount cannot be negative";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);

                            final userProfileProvider =
                                Provider.of<UserProfileProvider>(context, listen: false);
                            final success = await userProfileProvider.setInitialBalance(
                              double.parse(amountController.text),
                            );

                            setState(() => _isLoading = false);

                            if (success && mounted) {
                              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: ${userProfileProvider.error ?? "Failed to save balance"}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Continue",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final userProfileProvider =
                      Provider.of<UserProfileProvider>(context, listen: false);
                  await userProfileProvider.setInitialBalance(0.0);
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                  }
                },
                child: const Text("Skip for now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

