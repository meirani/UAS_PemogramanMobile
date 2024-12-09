import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/routes.dart';

Future<String> getInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  return isLoggedIn ? '/dashboard' : '/'; // Jika login, arahkan ke dashboard
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await getInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Point of Sale',
      initialRoute: initialRoute, // Gunakan route awal yang ditentukan
      getPages: AppRoutes.routes,
    );
  }
}
