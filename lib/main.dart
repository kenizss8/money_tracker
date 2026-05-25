import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'utils/app_colors.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');

  Object? firebaseInitializationError;

  try {
    await Firebase.initializeApp();
  } catch (error) {
    firebaseInitializationError = error;
  }

  runApp(
    BootstrapApp(firebaseInitializationError: firebaseInitializationError),
  );
}

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({super.key, this.firebaseInitializationError});

  final Object? firebaseInitializationError;

  @override
  Widget build(BuildContext context) {
    if (firebaseInitializationError != null) {
      return MoneyTrackerApp(
        home: SplashScreen(
          firebaseReady: false,
          firebaseInitializationError: firebaseInitializationError,
        ),
      );
    }

    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, firestoreService),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider(firestoreService),
        ),
        ChangeNotifierProvider<BudgetProvider>(
          create: (_) => BudgetProvider(firestoreService),
        ),
      ],
      child: const MoneyTrackerApp(home: SplashScreen()),
    );
  }
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
        );

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const <Locale>[Locale('vi', 'VN'), Locale('en', 'US')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
        ),
      ),
      home: home,
    );
  }
}
