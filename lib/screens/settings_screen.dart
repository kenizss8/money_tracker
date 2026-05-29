import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_button.dart';
import 'budget_editor_screen.dart';
import 'login_screen.dart';

const Color _accountCard = Color(0xFF1C1C1E);
const Color _accountBorder = Color(0xFF34343A);
const Color _accountText = Color(0xFFFFFFFF);
const Color _accountTextMuted = Color(0xFFA1A1AA);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openBudgetScreen(BuildContext context) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const BudgetEditorScreen()),
    );

    if (!context.mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteAllTransactions(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa toàn bộ giao dịch'),
          content: const Text(
            'Hành động này sẽ xóa toàn bộ giao dịch của bạn. Bạn có chắc chắn không?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa hết'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool success = await context
        .read<TransactionProvider>()
        .deleteAllTransactions();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xóa toàn bộ giao dịch' : 'Không thể xóa dữ liệu',
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final AuthProvider authProvider = context.read<AuthProvider>();
    final TransactionProvider transactionProvider = context
        .read<TransactionProvider>();
    final BudgetProvider budgetProvider = context.read<BudgetProvider>();

    await authProvider.logout();
    transactionProvider.bindUser(null);
    budgetProvider.bindUser(null);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<Widget>(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, TransactionProvider, BudgetProvider>(
      builder:
          (
            BuildContext context,
            AuthProvider authProvider,
            TransactionProvider transactionProvider,
            BudgetProvider budgetProvider,
            Widget? child,
          ) {
            final DateTime? createdAt = authProvider.userModel?.createdAt;

            return SafeArea(
              child: Theme(
                data: Theme.of(context).copyWith(
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: _accountBorder),
                    ),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 132),
                  children: <Widget>[
                    const Text(
                      'Tài khoản',
                      style: TextStyle(
                        color: _accountText,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _accountCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _accountBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Thông tin cá nhân',
                            style: TextStyle(
                              color: _accountText,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Họ tên',
                            value:
                                authProvider.userModel?.name ??
                                'Chưa có dữ liệu',
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value:
                                authProvider.userModel?.email ??
                                authProvider.firebaseUser?.email ??
                                'Chưa có dữ liệu',
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Ngày tạo',
                            value: createdAt == null
                                ? 'Chưa có dữ liệu'
                                : DateFormatter.formatDate(createdAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _accountCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _accountBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Thông tin ứng dụng',
                            style: TextStyle(
                              color: _accountText,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _InfoRow(
                            icon: Icons.apps_rounded,
                            label: 'Tên app',
                            value: AppConstants.appName,
                          ),
                          _InfoRow(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Ngân sách tháng',
                            value: budgetProvider.currentBudget == null
                                ? 'Chưa thiết lập'
                                : CurrencyFormatter.format(
                                    budgetProvider.currentBudget!.amount,
                                  ),
                          ),
                          _InfoRow(
                            icon: Icons.receipt_rounded,
                            label: 'Số giao dịch',
                            value: transactionProvider.transactions.length
                                .toString(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Đặt hoặc cập nhật ngân sách',
                      icon: Icons.savings_rounded,
                      onPressed: () => _openBudgetScreen(context),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Xóa toàn bộ giao dịch',
                      icon: Icons.delete_sweep_rounded,
                      isOutlined: true,
                      onPressed: () => _deleteAllTransactions(context),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Đăng xuất',
                      icon: Icons.logout_rounded,
                      isOutlined: true,
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: _accountTextMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: _accountText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
