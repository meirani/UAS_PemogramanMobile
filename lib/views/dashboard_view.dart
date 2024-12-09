import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Map<String, dynamic>> transactions = [];
  List<BarChartGroupData> salesData = [];
  int totalTransactions = 0;
  double totalSales = 0.0;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/uas_pemmob/api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'getTransactions'}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            transactions =
                List<Map<String, dynamic>>.from(responseData['data']);
            salesData = processSalesData(transactions);
            calculateTotals(transactions);
          });
        } else {
          Get.snackbar('Error', responseData['message']);
        }
      } else {
        Get.snackbar('Error', 'Failed to connect to server');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void calculateTotals(List<Map<String, dynamic>> transactions) {
    DateTime today = DateTime.now();
    String todayStr = DateFormat('yyyy-MM-dd').format(today);

    totalTransactions = transactions
        .where((transaction) => transaction['created_at'] == todayStr)
        .length;

    totalSales = transactions
        .where((transaction) => transaction['created_at'] == todayStr)
        .fold(0.0, (sum, item) => sum + item['total']);
  }

  List<BarChartGroupData> processSalesData(
      List<Map<String, dynamic>> transactions) {
    Map<String, double> dailySales = {};

    for (var transaction in transactions) {
      String createdAtStr = transaction['created_at'];
      DateTime createdAt;

      try {
        createdAt = DateFormat('yyyy-MM-dd').parseStrict(createdAtStr);
      } catch (e) {
        continue;
      }

      final date = DateFormat('yyyy-MM-dd').format(createdAt);
      dailySales[date] = (dailySales[date] ?? 0) + transaction['total'];
    }

    List<BarChartGroupData> barGroups = [];
    int xIndex = 0;

    dailySales.forEach((date, total) {
      barGroups.add(
        BarChartGroupData(
          x: xIndex,
          barRods: [
            BarChartRodData(
              toY: total,
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      xIndex++;
    });

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.trending_up, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Jumlah Transaksi Hari Ini',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            totalTransactions.toString(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    color: Colors.green[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.attach_money, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Total Penjualan Hari Ini (Rp)',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rp ${totalSales.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Grafik Penjualan Hari Ini',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20),
            if (salesData.isEmpty)
              Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    barGroups: salesData,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBorder:
                            BorderSide(color: Colors.blueGrey), // Border color
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            'Rp ${rod.toY.toStringAsFixed(0)}',
                            TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value % 200000 == 0) {
                              return Text('Rp ${value ~/ 1000}K',
                                  style: TextStyle(fontFamily: 'Poppins'));
                            }
                            return Container();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            'Day ${value.toInt()}',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
