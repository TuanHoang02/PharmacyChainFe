import 'package:flutter/material.dart';

class OperationsManagerMainLayout extends StatelessWidget {
  final Widget child;

  const OperationsManagerMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operations Manager Layout')),
      body: child,
    );
  }
}
