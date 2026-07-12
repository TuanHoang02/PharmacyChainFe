import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/core/routes/app_router.dart';

void main() {
  runApp(const PharmaCareApp());
}

class PharmaCareApp extends StatelessWidget {
  const PharmaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PharmaCare – Quản lý chuỗi nhà thuốc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      routerConfig: AppRouter.router,
    );
  }
}
