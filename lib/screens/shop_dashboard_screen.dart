import 'package:flutter/material.dart';
import 'package:frip_cash/screens/seller_dashboard_screen.dart';

/// Boutique entry — seller dashboard with shop branding and boutique KPIs.
class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SellerDashboardScreen(forceBoutique: true);
  }
}
