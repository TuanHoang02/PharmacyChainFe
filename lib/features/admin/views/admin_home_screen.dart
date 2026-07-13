import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chào mừng Quản trị viên (Admin)', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
