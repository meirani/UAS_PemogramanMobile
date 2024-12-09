import 'package:get/get.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';
import '../views/cashier_view.dart'; // Import halaman CashierView

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => LoginView()),
    GetPage(name: '/dashboard', page: () => DashboardView()),
    GetPage(
        name: '/cashier',
        page: () => CashierView()), // Tambahkan route untuk CashierView
  ];
}
