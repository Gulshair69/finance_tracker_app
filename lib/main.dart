import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<TransactionProvider, AnalyticsProvider>(
          create: (_) {
            final analytics = AnalyticsProvider();
            return analytics;
          },
          update: (_, transactionProvider, analytics) {
            analytics?.setTransactionProvider(transactionProvider);
            return analytics ?? AnalyticsProvider();
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Finance Manager',
        theme: themeProvider.isDarkBlue ? _buildDarkBlueTheme() : _buildLightTheme(),
        initialRoute: SplashScreen.routeName,
        routes: AppRoutes.routes,
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        background: AppColors.background,
        error: Colors.red.shade400,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.text,
        onBackground: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ThemeData _buildDarkBlueTheme() {
    return ThemeData(
      primaryColor: AppColors.darkBlue,
      scaffoldBackgroundColor: AppColors.darkBlue,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkBlue,
        secondary: AppColors.yellow,
        surface: AppColors.darkBlueAccent,
        background: AppColors.darkBlue,
        error: AppColors.trueRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.darkBlue,
        onSurface: AppColors.white,
        onBackground: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.yellow,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.darkBlue,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.darkBlue,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBlueAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.white),
        bodyMedium: TextStyle(color: AppColors.white),
        bodySmall: TextStyle(color: AppColors.white),
        titleLarge: TextStyle(color: AppColors.yellow),
        titleMedium: TextStyle(color: AppColors.yellow),
        titleSmall: TextStyle(color: AppColors.yellow),
      ),
    );
  }
}
