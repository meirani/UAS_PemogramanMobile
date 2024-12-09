// views/cashier_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert'; // Untuk JSON encoding dan decoding
import 'package:http/http.dart'
    as http; // Tambahkan dependensi http untuk HTTP request
import '../widgets/sidebar.dart';

class CashierView extends StatefulWidget {
  @override
  _CashierViewState createState() => _CashierViewState();
}

class _CashierViewState extends State<CashierView> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cart = [];

  void addProduct() {
    final name = productNameController.text;
    final price = double.tryParse(productPriceController.text) ?? 0.0;

    if (name.isNotEmpty && price > 0) {
      setState(() {
        products.add({'name': name, 'price': price});
      });
      productNameController.clear();
      productPriceController.clear();
    }
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
    });
  }

  void removeFromCart(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  double calculateTotal() {
    return cart.fold(0, (sum, item) => sum + item['price']);
  }

  // Fungsi untuk menyelesaikan transaksi dan mengirim data ke backend
  void completeTransaction() async {
    final total = calculateTotal();
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/uas_pemmob/api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'addTransaction',
          'cart': cart,
          'total': total,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          Get.snackbar('Success', 'Transaction completed successfully');
          setState(() {
            cart.clear();
          });
        } else {
          Get.snackbar('Error', responseData['message']);
        }
      } else {
        Get.snackbar(
            'Error', 'Failed to connect to server: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kasir')),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  TextField(
                    controller: productNameController,
                    decoration: InputDecoration(labelText: 'Nama Produk'),
                  ),
                  TextField(
                    controller: productPriceController,
                    decoration: InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addProduct,
                    child: Text('Tambah Produk'),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView(
                      children: products
                          .map((product) => ListTile(
                                title: Text(product['name']),
                                subtitle: Text('Rp ${product['price']}'),
                                trailing: ElevatedButton(
                                  onPressed: () => addToCart(product),
                                  child: Text('Tambah ke Keranjang'),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text(
                    'Transaksi Saat Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text('1 x Rp ${item['price']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => removeFromCart(index),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Text(
                    'Total: Rp ${calculateTotal()}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: completeTransaction,
                    child: Text('Selesaikan Transaksi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
