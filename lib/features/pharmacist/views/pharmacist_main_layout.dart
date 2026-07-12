import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PharmacistMainLayout extends StatelessWidget {
  final Widget child;

  const PharmacistMainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/pharmacist/prescriptions')) {
      return 1;
    }
    if (location.startsWith('/pharmacist/medicines')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/pharmacist');
        break;
      case 1:
        context.go('/pharmacist/prescriptions');
        break;
      case 2:
        context.go('/pharmacist/medicines');
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
            icon: Icon(Icons.medical_services),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Prescriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicines',
          ),
        ],
      ),
    );
  }
}
