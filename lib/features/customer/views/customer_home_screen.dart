import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chào mừng Quý khách (Customer)', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
