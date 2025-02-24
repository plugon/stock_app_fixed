import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';

// 📌 종목 상세 정보 화면
// - 사용자가 선택한 관심종목의 세부 정보를 보여주는 화면
// - 현재가, 등락률, 거래량과 함께 주가 변동 차트를 제공
class StockDetailScreen extends StatefulWidget {
  final StockModel stock;

  // 📌 선택된 관심종목 데이터를 전달받음
  const StockDetailScreen({Key? key, required this.stock}) : super(key: key);

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  // 🔧 종목의 실시간 정보 저장
  late double price; // 현재가
  late double change; // 등락률
  late String volume; // 거래량
  List<FlSpot> chartData = []; // 실시간 차트 데이터
  bool isLoading = true; // 데이터 로딩 상태 표시

  @override
  void initState() {
    super.initState();
    // 🔧 화면 초기화 시 종목 데이터 로드
    _loadStockData();
  }

  // 🔧 종목 데이터를 API에서 가져오는 함수
  Future<void> _loadStockData() async {
    setState(() => isLoading = true);
    try {
      // ✅ StockAPIService에서 종목 세부 정보 가져오기
      final stockDetails = await StockAPIService.getStockDetails(widget.stock.name);
      setState(() {
        // 📌 받아온 데이터를 각 필드에 저장
        price = stockDetails['price'];
        change = stockDetails['change'];
        volume = stockDetails['volume'];
        chartData = _generateChartData(stockDetails['historicalPrices']);
        isLoading = false; // 로딩 완료
      });
    } catch (e) {
      // 데이터 로딩 실패 시 로그 출력
      print("❌ 데이터 로딩 오류: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔧 차트 데이터 생성 함수
  // - API에서 받은 히스토리 데이터를 차트 포맷으로 변환
  List<FlSpot> _generateChartData(List<double> historicalPrices) {
    return List.generate(
      historicalPrices.length,
      (index) => FlSpot(index.toDouble(), historicalPrices[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📌 상단 AppBar: 종목명 표시
      appBar: AppBar(
        title: Text("${widget.stock.name} 상세 정보"), // 종목명으로 화면 제목 설정
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      // 📌 본문 내용
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 스피너 표시
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 종목명
                  Text(
                    widget.stock.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // 📌 현재가
                  Text(
                    '현재가: ${price.toStringAsFixed(2)} 원',
                    style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  // 📌 등락률
                  Text(
                    '등락률: ${change >= 0 ? '▲' : '▼'} ${change.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 18, color: change >= 0 ? Colors.green : Colors.red),
                  ),
                  const SizedBox(height: 5),

                  // 📌 거래량
                  Text('거래량: $volume', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),

                  // 📊 실시간 차트 데이터 표시
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        // 🔧 차트의 타이틀 데이터 설정 (왼쪽, 아래쪽)
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        ),
                        borderData: FlBorderData(show: true), // 차트 외곽선 표시
                        lineBarsData: [
                          // 📌 차트에 표시할 데이터 설정
                          LineChartBarData(
                            spots: chartData, // 생성된 차트 데이터 적용
                            isCurved: true, // 곡선 처리
                            barWidth: 3, // 차트 선 두께
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                            ), // 차트 선의 색상 그라디언트
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
