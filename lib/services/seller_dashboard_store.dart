import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/models/seller_dashboard.dart';

class SellerDashboardStore extends ChangeNotifier {
  SellerDashboardStore._();
  static final SellerDashboardStore instance = SellerDashboardStore._();

  SellerDashboard? dashboard;
  bool loading = false;
  String? error;

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      dashboard = await MeApi.instance.fetchSellerDashboard();
      loading = false;
      notifyListeners();
    } on ApiException catch (e) {
      loading = false;
      error = e.message;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
