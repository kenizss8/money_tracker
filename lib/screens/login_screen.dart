import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearError();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AuthProvider authProvider = context.read<AuthProvider>();
    final bool success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<Widget>(builder: (_) => const MainScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Theo dõi thu chi cá nhân của bạn một cách gọn gàng hơn.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Nhập email của bạn',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email không được bỏ trống';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Mật khẩu không được bỏ trống';
                          }
                          return null;
                        },
                      ),
                      if (authProvider.errorMessage != null) ...<Widget>[
                        const SizedBox(height: 14),
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'Đăng nhập',
                        icon: Icons.login_rounded,
                        isLoading: authProvider.isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<Widget>(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
