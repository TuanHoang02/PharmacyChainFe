import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BranchManagerMainLayout extends StatelessWidget {
  final Widget child;

  const BranchManagerMainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/manager/inventory')) {
      return 1;
    }
    if (location.startsWith('/manager/reports')) {
      return 2;
    }
    return 0; // default to dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/manager');
        break;
      case 1:
        context.go('/manager/inventory');
        break;
      case 2:
        context.go('/manager/reports');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Branch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
