import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import 'add_edit_transaction_screen.dart';
import 'budget_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'transaction_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  TransactionProvider? _boundTransactionProvider;

  List<Widget> get _pages => <Widget>[
    HomeScreen(onOpenLedger: _openLedgerTab),
    const TransactionLedgerScreen(),
    const BudgetScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? uid = context.read<AuthProvider>().firebaseUser?.uid;
      final TransactionProvider transactionProvider = context
          .read<TransactionProvider>();
      transactionProvider.bindUser(uid);
      context.read<BudgetProvider>().bindUser(uid);
      context.read<BudgetProvider>().setSelectedMonth(
        transactionProvider.selectedMonth,
      );

      _boundTransactionProvider = transactionProvider;
      _boundTransactionProvider?.addListener(_syncBudgetMonth);
    });
  }

  void _syncBudgetMonth() {
    if (!mounted) {
      return;
    }
    final TransactionProvider? transactionProvider = _boundTransactionProvider;
    if (transactionProvider == null) {
      return;
    }
    context.read<BudgetProvider>().setSelectedMonth(
      transactionProvider.selectedMonth,
    );
  }

  void _openLedgerTab() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  void dispose() {
    _boundTransactionProvider?.removeListener(_syncBudgetMonth);
    super.dispose();
  }

  String get _title {
    switch (_currentIndex) {
      case 1:
        return 'Sổ giao dịch';
      case 2:
        return 'Ngân sách';
      case 3:
        return 'Tài khoản';
      default:
        return 'Tổng quan';
    }
  }

  Future<void> _openAddTransaction() async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const AddEditTransactionScreen(),
      ),
    );

    if (!mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverviewTab = _currentIndex == 0;
    final bool isLedgerTab = _currentIndex == 1;
    final bool isBudgetTab = _currentIndex == 2;
    final bool isAccountTab = _currentIndex == 3;
    final bool isDarkTab =
        isOverviewTab || isLedgerTab || isBudgetTab || isAccountTab;

    return Scaffold(
      backgroundColor: isDarkTab ? Colors.black : AppColors.background,
      appBar: isDarkTab ? null : AppBar(title: Text(_title)),
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.black,
            indicatorColor: const Color(0xFF1C1C1E),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((
              Set<WidgetState> states,
            ) {
              return IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? Colors.white
                    : Colors.white70,
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
              Set<WidgetState> states,
            ) {
              return TextStyle(
                color: states.contains(WidgetState.selected)
                    ? Colors.white
                    : Colors.white70,
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w900
                    : FontWeight.w700,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _navigationIndex,
          onDestinationSelected: (int value) {
            if (value == 2) {
              _openAddTransaction();
              return;
            }

            setState(() {
              _currentIndex = value > 2 ? value - 1 : value;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Sổ giao dịch',
            ),
            NavigationDestination(
              icon: _AddNavigationIcon(),
              selectedIcon: _AddNavigationIcon(),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings_rounded),
              label: 'Ngân sách',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle_rounded),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }

  int get _navigationIndex {
    return _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex;
  }
}

class _AddNavigationIcon extends StatelessWidget {
  const _AddNavigationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
    );
  }
}
