import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pharmacy_chain_fe/features/branch_manager/models/branch_dashboard.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/branch_dashboard_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/dashboard_body.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/dashboard_error_state.dart';

class BranchManagerHomeScreen extends StatefulWidget {
  const BranchManagerHomeScreen({super.key});

  @override
  State<BranchManagerHomeScreen> createState() => _BranchManagerHomeScreenState();
}

class _BranchManagerHomeScreenState extends State<BranchManagerHomeScreen> {
  final BranchDashboardService _service = BranchDashboardService();
  late Future<BranchDashboard> _future;

  static final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _future = _service.fetchDashboard();
  }

  Future<void> _refresh() async {
    final next = _service.fetchDashboard();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: FutureBuilder<BranchDashboard>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C48C)),
              );
            }
            if (snapshot.hasError) {
              return DashboardErrorState(
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                onRetry: _refresh,
              );
            }
            final dashboard = snapshot.data!;
            return RefreshIndicator(
              color: const Color(0xFF00C48C),
              onRefresh: _refresh,
              child: DashboardBody(
                dashboard: dashboard,
                moneyFormat: _moneyFormat,
                dateFormat: _dateFormat,
              ),
            );
          },
        ),
      ),
    );
  }
}
