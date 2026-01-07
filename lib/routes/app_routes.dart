import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/category_management_screen.dart';
import '../screens/recurring_transactions_screen.dart';
import '../screens/initial_balance_screen.dart';

class AppRoutes {
  static const String splash = SplashScreen.routeName;
  static const String onboarding = OnboardingScreen.routeName;
  static const String welcome = WelcomeScreen.routeName;
  static const String login = LoginScreen.routeName;
  static const String signup = SignupScreen.routeName;
  static const String dashboard = DashboardScreen.routeName;
  static const String addTransaction = AddTransactionScreen.routeName;
  static const String history = HistoryScreen.routeName;
  static const String profile = ProfileScreen.routeName;
  static const String analytics = AnalyticsScreen.routeName;
  static const String budget = BudgetScreen.routeName;
  static const String categoryManagement = CategoryManagementScreen.routeName;
  static const String recurringTransactions = RecurringTransactionsScreen.routeName;
  static const String initialBalance = InitialBalanceScreen.routeName;

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    welcome: (_) => const WelcomeScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => SignupScreen(),
    dashboard: (_) => const DashboardScreen(),
    addTransaction: (_) => AddTransactionScreen(),
    history: (_) => HistoryScreen(),
    profile: (_) => ProfileScreen(),
    analytics: (_) => AnalyticsScreen(),
    budget: (_) => const BudgetScreen(),
    categoryManagement: (_) => const CategoryManagementScreen(),
    recurringTransactions: (_) => const RecurringTransactionsScreen(),
    initialBalance: (_) => const InitialBalanceScreen(),
  };
}
