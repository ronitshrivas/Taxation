import 'package:flutter/material.dart';

/// Application routing configuration
class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  
  // Income routes
  static const String incomeList = '/income/list';
  static const String addIncome = '/income/add';
  static const String editIncome = '/income/edit';
  static const String incomeDetail = '/income/detail';
  
  // Expense routes
  static const String expenseList = '/expense/list';
  static const String addExpense = '/expense/add';
  static const String editExpense = '/expense/edit';
  static const String expenseDetail = '/expense/detail';
  
  // Receipt routes
  static const String receiptScanner = '/receipt/scanner';
  static const String receiptGallery = '/receipt/gallery';
  static const String receiptDetail = '/receipt/detail';
  
  // Tax routes
  static const String taxCalculator = '/tax/calculator';
  static const String taxOptimization = '/tax/optimization';
  static const String taxBrackets = '/tax/brackets';
  
  // Reports routes
  static const String reports = '/reports';
  static const String reportPreview = '/reports/preview';
  static const String reportExport = '/reports/export';
  
  // AI Advisor routes
  static const String aiAdvisor = '/ai/advisor';
  static const String aiChat = '/ai/chat';
  
  // Settings routes
  static const String settingss = '/settings';
  static const String profile = '/settings/profile';
  static const String taxPreferences = '/settings/tax-preferences';
  static const String notifications = '/settings/notifications';
  static const String backup = '/settings/backup';
  static const String about = '/settings/about';
  static const String help = '/settings/help';

  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // SplashScreen
        );
      
      case login:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // LoginScreen
        );
      
      case register:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // RegisterScreen
        );
      
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // DashboardScreen
        );
      
      case addIncome:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // AddIncomeScreen
        );
      
      case addExpense:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // AddExpenseScreen
        );
      
      case receiptScanner:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // ReceiptScannerScreen
        );
      
      case taxCalculator:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TaxCalculatorScreen
        );
      
      case aiAdvisor:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // AIAdvisorScreen
        );
      
      case settingss:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // SettingsScreen
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
    }
  }

  /// Navigate to route
  static Future<dynamic> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace current route
  static Future<dynamic> navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and clear stack
  static Future<dynamic> navigateAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}

/// 404 Not Found Screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page transition animations
class AppPageRoute {
  /// Fade transition
  static Route fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Slide from right transition
  static Route slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom transition
  static Route slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Scale transition
  static Route scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}