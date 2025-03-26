import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/stock_model.dart';


class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool isLoading = false;
  
  final List<MarketIndex> _indices = [
    MarketIndex(
      name: "KOSPI",
      value: 2845.32,
      change: 1.25,
      isUp: true,
      historicalData: [2820.12, 2835.45, 2828.76, 2815.23, 2830.56, 2845.32],
    ),
    MarketIndex(
      name: "KOSDAQ",
      value: 932.17,
      change: 0.87,
      isUp: true,
      historicalData: [925.34, 928.67, 930.12, 927.89, 929.45, 932.17],
    ),
    MarketIndex(
      name: "S&P 500",
      value: 5123.45,
      change: -0.32,
      isUp: false,
      historicalData: [5135.67, 5142.23, 5138.45, 5130.12, 5125.78, 5123.45],
    ),
    MarketIndex(
      name: "NASDAQ",
      value: 16234.78,
      change: -0.45,
      isUp: false,
      historicalData: [16280.45, 16275.32, 16260.78, 16250.34, 16240.12, 16234.78],
    ),
    MarketIndex(
      name: "DOW",
      value: 38765.32,
      change: 0.12,
      isUp: true,
      historicalData: [38720.45, 38735.67, 38750.23, 38745.12, 38760.45, 38765.32],
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

  // 상승/하락 종목 비율 데이터
  final Map<String, double> _marketRatio = {
    '상승': 52.3,
    '하락': 43.7,
    '보합': 4.0,
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 데이터 새로고침 함수
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    
    // 실제 구현에서는 여기서 API 호출을 통해 데이터를 가져옴
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      isLoading = false;
    });
    
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "시장 동향",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '새로고침',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
          tabs: const [
            Tab(text: "주요 지수"),
            Tab(text: "업종별 동향"),
            Tab(text: "인기 종목"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildIndicesTab(context),
                _buildSectorsTab(context),
                _buildHotStocksTab(context),
              ],
            ),
    );
  }

  Widget _buildIndicesTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상승/하락 종목 비율 도넛 차트
            _buildMarketRatioChart(context),
            const SizedBox(height: 24),
            
            Text(
              "주요 지수 현황",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // 주요 지수 리스트
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _indices.length,
              itemBuilder: (context, i) {
                final marketIndex = _indices[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  marketIndex.name,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "현재 지수",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  marketIndex.value.toStringAsFixed(2),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      marketIndex.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: marketIndex.isUp ? AppColors.upColor : AppColors.downColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${marketIndex.isUp ? '+' : ''}${marketIndex.change.toStringAsFixed(2)}%",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: marketIndex.isUp ? AppColors.upColor : AppColors.downColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 미니 차트 추가
                        SizedBox(
                          height: 80,
                          child: _buildMiniChart(context, marketIndex),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 상승/하락 종목 비율 도넛 차트
  Widget _buildMarketRatioChart(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "상승/하락 종목 비율",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // 도넛 차트
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: _marketRatio['상승']!,
                          title: '${_marketRatio['상승']!.toStringAsFixed(1)}%',
                          color: AppColors.upColor,
                          radius: 30,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: _marketRatio['하락']!,
                          title: '${_marketRatio['하락']!.toStringAsFixed(1)}%',
                          color: AppColors.downColor,
                          radius: 30,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: _marketRatio['보합']!,
                          title: '${_marketRatio['보합']!.toStringAsFixed(1)}%',
                          color: AppColors.neutral,
                          radius: 30,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 범례
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(context, "상승", AppColors.upColor, _marketRatio['상승']!),
                      const SizedBox(height: 12),
                      _buildLegendItem(context, "하락", AppColors.downColor, _marketRatio['하락']!),
                      const SizedBox(height: 12),
                      _buildLegendItem(context, "보합", AppColors.neutral, _marketRatio['보합']!),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 범례 아이템
  Widget _buildLegendItem(BuildContext context, String label, Color color, double value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          "${value.toStringAsFixed(1)}%",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 미니 차트
  Widget _buildMiniChart(BuildContext context, MarketIndex index) {
    final spots = List.generate(
      index.historicalData.length,
      (i) => FlSpot(i.toDouble(), index.historicalData[i]),
    );
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: index.isUp ? AppColors.upColor : AppColors.downColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: index.isUp 
                ? AppColors.upColor.withOpacity(0.2) 
                : AppColors.downColor.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  Widget _buildSectorsTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 업종별 성과 히트맵
            _buildSectorHeatmap(context),
            const SizedBox(height: 24),
            
            Text(
              "업종별 등락률",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // 업종별 리스트
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sectors.length,
              itemBuilder: (context, index) {
                final sector = _sectors[index];
                final absChange = sector.change.abs();
                final progressValue = absChange / 3.0; // 최대 3%로 가정
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sector.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  sector.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: sector.isUp ? AppColors.upColor : AppColors.downColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${sector.isUp ? '+' : ''}${sector.change.toStringAsFixed(1)}%",
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: sector.isUp ? AppColors.upColor : AppColors.downColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 진행 표시줄
                        LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          color: sector.isUp ? AppColors.upColor : AppColors.downColor,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 업종별 성과 히트맵
  Widget _buildSectorHeatmap(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "업종별 성과 히트맵",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _sectors.length,
              itemBuilder: (context, index) {
                final sector = _sectors[index];
                final absChange = sector.change.abs();
                final opacity = 0.3 + (absChange / 3.0) * 0.7; // 변화량에 따른 투명도 조정
                
                return Container(
                  decoration: BoxDecoration(
                    color: sector.isUp 
                      ? AppColors.upColor.withOpacity(opacity) 
                      : AppColors.downColor.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sector.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${sector.isUp ? '+' : ''}${sector.change.toStringAsFixed(1)}%",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotStocksTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _hotStocks.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            // 헤더
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "오늘의 인기 종목",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                // 테이블 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "종목명",
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "현재가",
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "등락률",
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "거래량",
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerTheme.color,
                ),
                const SizedBox(height: 8),
              ],
            );
          }
          
          // 종목 아이템
          final stock = _hotStocks[index - 1];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 종목명
                  Expanded(
                    flex: 3,
                    child: Text(
                      stock.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // 현재가
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${stock.price.toStringAsFixed(0)}원",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  
                  // 등락률
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          stock.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          color: stock.isUp ? AppColors.upColor : AppColors.downColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${stock.isUp ? '+' : ''}${stock.change.toStringAsFixed(1)}%",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: stock.isUp ? AppColors.upColor : AppColors.downColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 거래량
                  Expanded(
                    flex: 2,
                    child: Text(
                      stock.volume,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MarketIndex {
  final String name;
  final double value;
  final double change;
  final bool isUp;
  final List<double> historicalData;

  MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.isUp,
    required this.historicalData,
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
  final double price;
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
