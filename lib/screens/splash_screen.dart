import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../routes/app_routes.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/user_profile_provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth state and navigate
    Timer(const Duration(seconds: 2), () async {
      final authProvider = Provider.of<app_auth.AuthProvider>(
        context,
        listen: false,
      );
      if (authProvider.user != null) {
        // Check if user has set initial balance
        final userProfileProvider = Provider.of<UserProfileProvider>(
          context,
          listen: false,
        );
        await userProfileProvider.checkUserProfile();
        if (userProfileProvider.hasProfile) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.initialBalance);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          "Finance Manager",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
