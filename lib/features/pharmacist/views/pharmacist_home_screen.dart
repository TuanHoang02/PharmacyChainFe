import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PharmacistHomeScreen extends StatelessWidget {
  const PharmacistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào mừng Dược sĩ (Pharmacist)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/pharmacist/sales');
              },
              icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
              label: const Text(
                'Lịch sử bán lẻ (Sales History)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
