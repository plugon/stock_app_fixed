import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';

class StockDetailScreen extends StatefulWidget {
  final StockModel stock;

  const StockDetailScreen({Key? key, required this.stock}) : super(key: key);

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late double price;
  late double change;
  late String volume;
  List<FlSpot> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    setState(() => isLoading = true);
    try {
      final stockDetails = await StockAPIService.getStockDetails(widget.stock.name);
      setState(() {
        price = stockDetails['price'];
        change = stockDetails['change'];
        volume = stockDetails['volume'];
        chartData = _generateChartData(stockDetails['historicalPrices']);
        isLoading = false;
      });
    } catch (e) {
      print("❌ 데이터 로딩 오류: $e");
      setState(() => isLoading = false);
    }
  }

  List<FlSpot> _generateChartData(List<double> historicalPrices) {
    return List.generate(
      historicalPrices.length,
      (index) => FlSpot(index.toDouble(), historicalPrices[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.stock.name} 상세 정보"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stock.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '현재가: ${price.toStringAsFixed(2)} 원',
                    style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '등락률: ${change >= 0 ? '▲' : '▼'} ${change.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 18, color: change >= 0 ? Colors.green : Colors.red),
                  ),
                  const SizedBox(height: 5),
                  Text('거래량: $volume', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),

                  // 📊 실시간 차트 데이터 표시
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData,
                            isCurved: true,
                            barWidth: 3,
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
