import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/admin_bottom_nav.dart';
import '../../providers/admin_provider.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'products/admin_products_screen.dart';
import 'profile/admin_profile_screen.dart';
import 'users/admin_users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  final _screens = const [
    AdminDashboardScreen(),
    AdminProductsScreen(),
    AdminOrdersScreen(),
    AdminUsersScreen(),
    AdminProfileScreen(),
  ];

  void _onTab(int i) {
    final provider = context.read<AdminProvider>();
    if (i == 0 && provider.stats == null) provider.loadDashboard();
    if (i == 1 && provider.products.items.isEmpty) provider.loadProducts();
    if (i == 2 && provider.orders.items.isEmpty) provider.loadOrders();
    if (i == 3 && provider.users.items.isEmpty) provider.loadUsers();
    setState(() => _index = i);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar:
          AdminBottomNav(currentIndex: _index, onTap: _onTab),
    );
  }
}