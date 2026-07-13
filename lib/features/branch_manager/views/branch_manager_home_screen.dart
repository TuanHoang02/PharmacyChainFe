import 'package:flutter/material.dart';

class BranchManagerHomeScreen extends StatelessWidget {
  const BranchManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chào mừng Quản lý Chi nhánh (Branch Manager)', style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
      ),
    );
  }
}
