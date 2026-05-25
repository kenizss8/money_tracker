import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_edit_transaction_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'statistic_screen.dart';
import 'transaction_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const <Widget>[
    HomeScreen(),
    TransactionListScreen(),
    StatisticScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? uid = context.read<AuthProvider>().firebaseUser?.uid;
      context.read<TransactionProvider>().bindUser(uid);
      context.read<BudgetProvider>().bindUser(uid);
    });
  }

  String get _title {
    switch (_currentIndex) {
      case 1:
        return 'Giao dịch';
      case 2:
        return 'Thống kê';
      case 3:
        return 'Cài đặt';
      default:
        return 'Trang chủ';
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
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransaction,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm giao dịch'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Thống kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
