import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/auth/views/login_screen.dart';

class BranchManagerHomeScreen extends StatelessWidget {
  const BranchManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await LocalStorageService().clearAll();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Chào mừng Quản lý Chi nhánh (Branch Manager)', style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
      ),
    );
  }
}
