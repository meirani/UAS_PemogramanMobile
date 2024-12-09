import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatelessWidget {
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus data login
    Get.offAllNamed('/'); // Arahkan ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Point of Sale',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Get.offAllNamed('/dashboard');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Kasir'),
            onTap: () {
              Get.offAllNamed('/cashier');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: logout, // Memanggil fungsi logout
          ),
        ],
      ),
    );
  }
}
