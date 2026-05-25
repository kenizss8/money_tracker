import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.firebaseReady = true,
    this.firebaseInitializationError,
  });

  final bool firebaseReady;
  final Object? firebaseInitializationError;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.firebaseReady) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.warning,
                    child: Icon(
                      Icons.settings_suggest_rounded,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chưa cấu hình Firebase',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hãy thêm file google-services.json vào android/app rồi chạy lại ứng dụng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${widget.firebaseInitializationError}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final AuthProvider authProvider = context.watch<AuthProvider>();

    if (!authProvider.isCheckingAuth && !_hasNavigated) {
      _hasNavigated = true;
      final NavigatorState navigator = Navigator.of(context);
      Future<void>.delayed(AppConstants.splashDuration, () {
        if (!mounted) {
          return;
        }
        navigator.pushReplacement(
          MaterialPageRoute<Widget>(
            builder: (_) => authProvider.isAuthenticated
                ? const MainScreen()
                : const LoginScreen(),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppConstants.appTagline,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 36),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
