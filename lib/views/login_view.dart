import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // Menyimpan status login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Periksa apakah login berhasil
                bool isLoggedIn = loginController.login(
                  usernameController.text,
                  passwordController.text,
                );

                if (isLoggedIn) {
                  await saveLoginStatus(); // Simpan status login
                  Get.offAllNamed('/dashboard'); // Arahkan ke dashboard
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
