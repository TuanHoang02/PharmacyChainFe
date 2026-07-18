import 'package:flutter/material.dart';

class SupplierHomeScreen extends StatelessWidget {
  const SupplierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A1628),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined,
                    color: Color(0xFF00C48C), size: 72),
                SizedBox(height: 16),
                Text(
                  'Chào mừng Nhà cung cấp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sử dụng tab "Đơn mua" để xem danh sách đơn đặt hàng từ các chi nhánh.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8FA8C9), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
