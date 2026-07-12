import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';

import 'package:pharmacy_chain_fe/features/auth/views/splash_screen.dart';
import 'package:pharmacy_chain_fe/features/auth/views/login_screen.dart';

import 'package:pharmacy_chain_fe/features/admin/views/admin_main_layout.dart';
import 'package:pharmacy_chain_fe/features/admin/views/admin_home_screen.dart';

import 'package:pharmacy_chain_fe/features/branch_manager/views/branch_manager_main_layout.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/views/branch_manager_home_screen.dart';

import 'package:pharmacy_chain_fe/features/pharmacist/views/pharmacist_main_layout.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/views/pharmacist_home_screen.dart';

import 'package:pharmacy_chain_fe/features/customer/views/customer_main_layout.dart';
import 'package:pharmacy_chain_fe/features/customer/views/customer_home_screen.dart';

class AppRouter {
  static final LocalStorageService _storageService = LocalStorageService();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    
    redirect: (BuildContext context, GoRouterState state) async {
      final token = await _storageService.getToken();
      final role = await _storageService.getRole();
      
      final isLoggedIn = token != null && token.isNotEmpty;
      final location = state.uri.toString();
      
      final isGoingToAuth = location == '/login';
      final isSplash = location == '/splash';

      if (!isLoggedIn && !isGoingToAuth && !isSplash) {
        return '/login';
      }

      if (isLoggedIn && isGoingToAuth) {
        if (role == 'admin') return '/admin';
        if (role == 'branchmanager' || role == 'branch manager') return '/manager';
        if (role == 'pharmacist') return '/pharmacist';
        if (role == 'customer') return '/customer';
        return '/login';
      }

      // Route Guards
      if (isLoggedIn) {
        if (location.startsWith('/admin') && role != 'admin') {
          return '/login';
        }
        if (location.startsWith('/manager') && (role != 'branchmanager' && role != 'branch manager')) {
          return '/login';
        }
        if (location.startsWith('/pharmacist') && role != 'pharmacist') {
          return '/login';
        }
        if (location.startsWith('/customer') && role != 'customer') {
          return '/login';
        }
      }

      return null;
    },
    
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Admin Routes
      ShellRoute(
        builder: (context, state, child) => AdminMainLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminHomeScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Users'))),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Settings'))),
          ),
        ],
      ),

      // Branch Manager Routes
      ShellRoute(
        builder: (context, state, child) => BranchManagerMainLayout(child: child),
        routes: [
          GoRoute(
            path: '/manager',
            builder: (context, state) => const BranchManagerHomeScreen(),
          ),
          GoRoute(
            path: '/manager/inventory',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Manager Inventory'))),
          ),
          GoRoute(
            path: '/manager/reports',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Manager Reports'))),
          ),
        ],
      ),

      // Pharmacist Routes
      ShellRoute(
        builder: (context, state, child) => PharmacistMainLayout(child: child),
        routes: [
          GoRoute(
            path: '/pharmacist',
            builder: (context, state) => const PharmacistHomeScreen(),
          ),
          GoRoute(
            path: '/pharmacist/prescriptions',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Pharmacist Prescriptions'))),
          ),
          GoRoute(
            path: '/pharmacist/medicines',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Pharmacist Medicines'))),
          ),
        ],
      ),

      // Customer Routes
      ShellRoute(
        builder: (context, state, child) => CustomerMainLayout(child: child),
        routes: [
          GoRoute(
            path: '/customer',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/customer/orders',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Customer Orders'))),
          ),
          GoRoute(
            path: '/customer/profile',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Customer Profile'))),
          ),
        ],
      ),
    ],
  );
}
