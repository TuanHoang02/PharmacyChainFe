import 'package:flutter/material.dart';

class PharmacistHomeScreen extends StatelessWidget {
  const PharmacistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chào mừng Dược sĩ (Pharmacist)', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
