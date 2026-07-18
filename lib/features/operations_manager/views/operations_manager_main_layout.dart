import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OperationsManagerMainLayout extends StatelessWidget {
  final Widget child;

  const OperationsManagerMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PharmaCare - Operations')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Operations Manager Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                context.go('/operations');
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Branch Performance'),
              onTap: () {
                context.go('/operations/branch-performance');
                Navigator.pop(context); // Close drawer
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
