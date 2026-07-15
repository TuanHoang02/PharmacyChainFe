import 'package:flutter/material.dart';

class SupplierMainLayout extends StatelessWidget {
  final Widget child;

  const SupplierMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supplier Layout')),
      body: child,
    );
  }
}
