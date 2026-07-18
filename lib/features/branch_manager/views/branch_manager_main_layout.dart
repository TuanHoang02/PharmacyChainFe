import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/auth/services/auth_service.dart';

class BranchManagerMainLayout extends StatelessWidget {
  final Widget child;

  const BranchManagerMainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    // TODO: re-add inventory index when implemented
    if (location.startsWith('/manager/reports')) {
      return 1;
    }
    return 0; // default to dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/manager');
        break;
      // TODO: re-add inventory case when implemented
      // case 1:
      //   context.go('/manager/inventory');
      //   break;
      case 1:
        context.go('/manager/reports');
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Branch',
          ),
          // TODO: implement inventory management feature
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.inventory),
          //   label: 'Inventory',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
