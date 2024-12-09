import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLogged = false.obs;

  bool login(String username, String password) {
    if (username == 'H1D022108' && password == '12345') {
      isLogged.value = true;
      return true; // Login berhasil
    } else {
      Get.snackbar('Error', 'Username atau password salah');
      return false; // Login gagal
    }
  }
}
