import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tax/data/datasources/local/hive_database.dart';
import 'package:tax/presentation/screens/auth/login_screen.dart';
import 'package:tax/presentation/screens/dashboard/dashboard_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'data/models/user_model.dart';
import 'data/models/income_model.dart';
import 'data/models/expense_model.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await HiveDatabase().init();  // This sets up Hive and opens boxes on the instance

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive database
  //await _initHive();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: TaxSathiApp(),
    ),
  );
}

/// Initialize Hive database
Future<void> init() async {
  // Get application documents directory
  final appDocumentDir = await getApplicationDocumentsDirectory();
  
  // Initialize Hive
  await Hive.initFlutter(appDocumentDir.path);

  // Register adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(IncomeAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  // Open boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Income>('incomes');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox('settings'); // For app settings
  await Hive.openBox('cache'); // For cached data
}

/// Main application widget
class TaxSathiApp extends ConsumerWidget {
  const TaxSathiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode provider (will be implemented)
    // final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light theme
      
      // Localization (will be implemented)
      // locale: Locale('en'),
      // supportedLocales: const [
      //   Locale('en', ''),
      //   Locale('ne', ''),
      // ],
      
      // Home screen (will navigate based on auth state)
      home: const SplashScreen(),
      
      // Named routes (will be expanded)
      // routes: AppRouter.routes,
      
      // Builder for global UI features
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scale doesn't exceed 1.3
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Splash screen - displayed while app initializes
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to next screen after delay
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    final userBox = Hive.box<User>('users');
    final hasUser = userBox.isNotEmpty;

    // Navigate based on authentication state
    // For now, just show a placeholder
   Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => hasUser
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF1976D2),
              Color(0xFF2196F3),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo (placeholder icon for now)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 60,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App name
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tagline
                  const Text(
                    AppStrings.appTagline,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Inter',
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading indicator
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder home screen (to be replaced)
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaxSathi Nepal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to TaxSathi!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your tax management dashboard will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Clear user data for testing
                Hive.box<User>('users').clear();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const PlaceholderLoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout (Test)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder login screen (to be replaced)
class PlaceholderLoginScreen extends StatelessWidget {
  const PlaceholderLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 50,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'TaxSathi Nepal',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'AI-Powered Tax Intelligence',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Login form will be implemented here
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Login Screen',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Full authentication system will be implemented in the next phase.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // Create demo user for testing
                              final userBox = Hive.box<User>('users');
                              final demoUser = User(
                                id: '1',
                                email: 'demo@taxsathi.com',
                                name: 'Demo User',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              userBox.add(demoUser);
                              
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const PlaceholderHomeScreen(),
                                ),
                              );
                            },
                            child: const Text('Continue as Demo User'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}