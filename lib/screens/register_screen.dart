import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AuthProvider authProvider = context.read<AuthProvider>();
    final bool success = await authProvider.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký tài khoản thành công')),
      );
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
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Tạo tài khoản mới',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lưu thông tin cá nhân và bắt đầu quản lý chi tiêu ngay hôm nay.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Họ tên',
                        hintText: 'Nhập họ tên của bạn',
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Họ tên không được bỏ trống';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                        hintText: 'Tối thiểu 6 ký tự',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Mật khẩu không được bỏ trống';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu tối thiểu 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Xác nhận mật khẩu',
                        hintText: 'Nhập lại mật khẩu',
                        obscureText: true,
                        prefixIcon: Icons.lock_person_outlined,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _passwordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
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
                        label: 'Đăng ký',
                        icon: Icons.person_add_alt_1_rounded,
                        isLoading: authProvider.isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Đã có tài khoản? Quay lại đăng nhập',
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
