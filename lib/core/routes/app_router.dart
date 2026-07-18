import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';

import 'package:pharmacy_chain_fe/features/auth/views/splash_screen.dart';
import 'package:pharmacy_chain_fe/features/auth/views/login_screen.dart';
import 'package:pharmacy_chain_fe/features/auth/views/change_password_screen.dart';

import 'package:pharmacy_chain_fe/features/admin/views/admin_main_layout.dart';
import 'package:pharmacy_chain_fe/features/admin/views/admin_home_screen.dart';

import 'package:pharmacy_chain_fe/features/branch_manager/views/branch_manager_main_layout.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/views/branch_manager_home_screen.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/views/branch_staff_screen.dart';

import 'package:pharmacy_chain_fe/features/pharmacist/views/pharmacist_main_layout.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/views/pharmacist_home_screen.dart';

import 'package:pharmacy_chain_fe/features/operations_manager/views/operations_manager_main_layout.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/views/operations_manager_home_screen.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/views/branch_list_screen.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/views/branch_form_screen.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/views/category_list_screen.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/views/supplier_list_screen.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/views/staff_management_screen.dart';

import 'package:pharmacy_chain_fe/features/supplier/views/supplier_main_layout.dart';
import 'package:pharmacy_chain_fe/features/supplier/views/supplier_home_screen.dart';

import 'package:pharmacy_chain_fe/features/shared/views/staff_form_screen.dart';

class AppRouter {
  static final LocalStorageService _storageService = LocalStorageService();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    
    redirect: (BuildContext context, GoRouterState state) async {
      final token = await _storageService.getToken();
      final rawRole = await _storageService.getRole();
      final role = rawRole?.toLowerCase();
      
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
        if (role == 'operationsmanager' || role == 'operations manager') return '/operations';
        if (role == 'supplier') return '/supplier';

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
        if (location.startsWith('/operations') && (role != 'operationsmanager' && role != 'operations manager')) {
          return '/login';
        }
        if (location.startsWith('/supplier') && role != 'supplier') {
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
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
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
            path: '/manager/staff',
            builder: (context, state) => const BranchStaffScreen(),
          ),
          GoRoute(
            path: '/manager/staff/new',
            builder: (context, state) => const StaffFormScreen(),
          ),
          GoRoute(
            path: '/manager/staff/edit/:id',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = idStr != null ? int.tryParse(idStr) : null;
              return StaffFormScreen(staffId: id);
            },
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

      // Operations Manager Routes
      ShellRoute(
        builder: (context, state, child) => OperationsManagerMainLayout(child: child),
        routes: [
          GoRoute(
            path: '/operations',
            builder: (context, state) => const OperationsManagerHomeScreen(),
          ),
          GoRoute(
            path: '/operations/branches',
            builder: (context, state) => const BranchListScreen(),
          ),
          GoRoute(
            path: '/operations/branches/new',
            builder: (context, state) => const BranchFormScreen(),
          ),
          GoRoute(
            path: '/operations/branches/edit/:id',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = idStr != null ? int.tryParse(idStr) : null;
              return BranchFormScreen(branchId: id);
            },
          ),
          GoRoute(
            path: '/operations/categories',
            builder: (context, state) => const CategoryListScreen(),
          ),
          GoRoute(
            path: '/operations/suppliers',
            builder: (context, state) => const SupplierListScreen(),
          ),
          GoRoute(
            path: '/operations/staff',
            builder: (context, state) => const StaffManagementScreen(),
          ),
          GoRoute(
            path: '/operations/staff/new',
            builder: (context, state) => const StaffFormScreen(),
          ),
          GoRoute(
            path: '/operations/staff/edit/:id',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = idStr != null ? int.tryParse(idStr) : null;
              return StaffFormScreen(staffId: id);
            },
          ),
        ],
      ),

      // Supplier Routes
      ShellRoute(
        builder: (context, state, child) => SupplierMainLayout(child: child),
        routes: [
          GoRoute(
            path: '/supplier',
            builder: (context, state) => const SupplierHomeScreen(),
          ),
        ],
      ),
    ],
  );
}
