import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<MarketIndex> _indices = [
    MarketIndex(
      name: "KOSPI",
      value: 2845.32,
      change: 1.25,
      isUp: true,
    ),
    MarketIndex(
      name: "KOSDAQ",
      value: 932.17,
      change: 0.87,
      isUp: true,
    ),
    MarketIndex(
      name: "S&P 500",
      value: 5123.45,
      change: -0.32,
      isUp: false,
    ),
    MarketIndex(
      name: "NASDAQ",
      value: 16234.78,
      change: -0.45,
      isUp: false,
    ),
    MarketIndex(
      name: "DOW",
      value: 38765.32,
      change: 0.12,
      isUp: true,
    ),
  ];

  final List<SectorPerformance> _sectors = [
    SectorPerformance(name: "IT", change: 2.3, isUp: true),
    SectorPerformance(name: "금융", change: 1.5, isUp: true),
    SectorPerformance(name: "에너지", change: -0.8, isUp: false),
    SectorPerformance(name: "헬스케어", change: 0.7, isUp: true),
    SectorPerformance(name: "소비재", change: -0.3, isUp: false),
    SectorPerformance(name: "통신", change: 1.2, isUp: true),
    SectorPerformance(name: "산업재", change: 0.5, isUp: true),
    SectorPerformance(name: "유틸리티", change: -0.2, isUp: false),
    SectorPerformance(name: "부동산", change: -1.1, isUp: false),
    SectorPerformance(name: "원자재", change: 0.9, isUp: true),
  ];

  final List<HotStock> _hotStocks = [
    HotStock(name: "삼성전자", price: 72500, change: 2.3, isUp: true, volume: "3.2M"),
    HotStock(name: "SK하이닉스", price: 142000, change: 3.1, isUp: true, volume: "1.5M"),
    HotStock(name: "LG에너지솔루션", price: 387000, change: -0.8, isUp: false, volume: "0.9M"),
    HotStock(name: "NAVER", price: 215000, change: 1.2, isUp: true, volume: "0.7M"),
    HotStock(name: "카카오", price: 56700, change: -1.5, isUp: false, volume: "1.1M"),
    HotStock(name: "현대차", price: 187500, change: 0.5, isUp: true, volume: "0.6M"),
    HotStock(name: "기아", price: 83400, change: 0.7, isUp: true, volume: "0.8M"),
    HotStock(name: "POSCO홀딩스", price: 423000, change: -0.3, isUp: false, volume: "0.4M"),
    HotStock(name: "삼성바이오로직스", price: 782000, change: 1.8, isUp: true, volume: "0.3M"),
    HotStock(name: "LG화학", price: 512000, change: 2.1, isUp: true, volume: "0.5M"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📈 시장 동향",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "주요 지수"),
            Tab(text: "업종별 동향"),
            Tab(text: "인기 종목"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIndicesTab(),
          _buildSectorsTab(),
          _buildHotStocksTab(),
        ],
      ),
    );
  }

  Widget _buildIndicesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "주요 지수 현황",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _indices.length,
              itemBuilder: (context, i) {
                final marketIndex = _indices[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              marketIndex.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "현재 지수",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              marketIndex.value.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${marketIndex.isUp ? '+' : ''}${marketIndex.change.toStringAsFixed(2)}%",
                              style: TextStyle(
                                fontSize: 14,
                                color: marketIndex.isUp ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "업종별 등락률",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _sectors.length,
              itemBuilder: (context, index) {
                final sector = _sectors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sector.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              sector.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                              color: sector.isUp ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${sector.isUp ? '+' : ''}${sector.change.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 16,
                                color: sector.isUp ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotStocksTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "오늘의 인기 종목",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _hotStocks.length,
              itemBuilder: (context, index) {
                final stock = _hotStocks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stock.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "거래량: ${stock.volume}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${stock.price.toString()} 원",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${stock.isUp ? '+' : ''}${stock.change.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: stock.isUp ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MarketIndex {
  final String name;
  final double value;
  final double change;
  final bool isUp;

  MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.isUp,
  });
}

class SectorPerformance {
  final String name;
  final double change;
  final bool isUp;

  SectorPerformance({
    required this.name,
    required this.change,
    required this.isUp,
  });
}

class HotStock {
  final String name;
  final int price;
  final double change;
  final bool isUp;
  final String volume;

  HotStock({
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
    required this.volume,
  });
}
