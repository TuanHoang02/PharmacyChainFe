import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/auth/services/auth_service.dart';

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
    if (location.startsWith('/pharmacist/sales')) {
      return 3;
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
      case 3:
        context.go('/pharmacist/sales');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Chain'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'change_password') {
                context.push('/change-password');
              } else if (value == 'logout') {
                await AuthService().logout();
                await LocalStorageService().clearAll();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(Icons.lock_reset, size: 20),
                    SizedBox(width: 8),
                    Text('Đổi mật khẩu'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout),
            label: 'Bán hàng',
          ),
        ],
      ),
    );
  }
}
