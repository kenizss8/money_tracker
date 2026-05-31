import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

const Color _background = Colors.black;
const Color _card = Color(0xFF1C1C1E);
const Color _text = Colors.white;
const Color _muted = Color(0xFFA1A1AA);
const Color _green = Color(0xFF34D399);
const Color _blue = Color(0xFF60A5FA);
const Color _red = Color(0xFFFB7185);

class WalletListScreen extends StatelessWidget {
  const WalletListScreen({
    super.key,
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
  });

  final double balance;
  final double monthIncome;
  final double monthExpense;

  @override
  Widget build(BuildContext context) {
    final List<_WalletAccountViewData> accounts = <_WalletAccountViewData>[
      _WalletAccountViewData(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Số dư hiện tại',
        amount: balance,
        color: _green,
      ),
      _WalletAccountViewData(
        icon: Icons.trending_up_rounded,
        title: 'Thu nhập tháng này',
        amount: monthIncome,
        color: _blue,
      ),
      _WalletAccountViewData(
        icon: Icons.shopping_bag_rounded,
        title: 'Chi tiêu tháng này',
        amount: -monthExpense,
        color: _red,
      ),
    ];

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Ví của tôi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _text,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 74),
              ],
            ),
            const SizedBox(height: 14),
            WalletAccountCard(
              icon: Icons.public_rounded,
              title: 'Tổng cộng',
              amount: balance,
              selected: true,
              color: _green,
            ),
            const SizedBox(height: 24),
            const Text(
              'TÍNH VÀO TỔNG',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(height: 12),
            for (final _WalletAccountViewData account in accounts)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WalletAccountCard(
                  icon: account.icon,
                  title: account.title,
                  amount: account.amount,
                  color: account.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WalletAccountCard extends StatelessWidget {
  const WalletAccountCard({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.color,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final double amount;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withValues(alpha: 0.16),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                CurrencyFormatter.format(amount),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: amount < 0 ? _red : _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (selected) ...<Widget>[
            const SizedBox(width: 10),
            const Icon(Icons.check_circle_rounded, color: _green, size: 22),
          ],
        ],
      ),
    );
  }
}

class _WalletAccountViewData {
  const _WalletAccountViewData({
    required this.icon,
    required this.title,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String title;
  final double amount;
  final Color color;
}
