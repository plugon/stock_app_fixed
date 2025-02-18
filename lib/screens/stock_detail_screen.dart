import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock_model.dart';

class StockDetailScreen extends StatelessWidget {
  final StockModel stock;

  StockDetailScreen({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${stock.name} 상세 정보')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '현재가: ${stock.price} 원',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 20),

            // ✅ 주가 변동 차트
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
                      spots: _getDummyChartData(),
                      isCurved: true,
                      barWidth: 3,
                      gradient: LinearGradient( // ✅ colors 대신 gradient 사용
                        colors: [Colors.blue, Colors.blueAccent],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // ✅ 최근 거래 정보
            Text(
              '📊 최근 거래 정보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildInfoRow('거래량', '1,500,000'),
            _buildInfoRow('변동률', '▲2.3%', textColor: Colors.green),
            _buildInfoRow('시가', '75,500 원'),
            _buildInfoRow('종가', '${stock.price} 원'),
          ],
        ),
      ),
    );
  }

  // ✅ 더미 차트 데이터 (나중에 실제 데이터로 대체 가능)
  List<FlSpot> _getDummyChartData() {
    return [
      FlSpot(0, 73.5),
      FlSpot(1, 74.2),
      FlSpot(2, 72.8),
      FlSpot(3, 75.3),
      FlSpot(4, 74.5),
      FlSpot(5, 76.0),
      FlSpot(6, 75.8),
    ];
  }

  // ✅ 거래 정보 행 생성 함수
  Widget _buildInfoRow(String label, String value, {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}
