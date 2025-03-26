import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/stock_model.dart';


class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with AutomaticKeepAliveClientMixin {
  final List<PortfolioItem> _portfolioItems = [
    PortfolioItem(
      stock: StockModel(
        name: "삼성전자",
        price: 72500,
        change: 2.3,
        volume: "3.2M",
      ),
      quantity: 10,
      purchasePrice: 68000,
      purchaseDate: "2025-01-15",
      targetPrice: 80000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "SK하이닉스",
        price: 142000,
        change: 3.1,
        volume: "1.5M",
      ),
      quantity: 5,
      purchasePrice: 135000,
      purchaseDate: "2025-02-03",
      targetPrice: 150000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "NAVER",
        price: 215000,
        change: 1.2,
        volume: "0.7M",
      ),
      quantity: 3,
      purchasePrice: 220000,
      purchaseDate: "2025-01-28",
      targetPrice: 250000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "카카오",
        price: 56700,
        change: -1.5,
        volume: "1.1M",
      ),
      quantity: 15,
      purchasePrice: 60000,
      purchaseDate: "2025-02-10",
      targetPrice: 65000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "현대차",
        price: 187500,
        change: 0.5,
        volume: "0.6M",
      ),
      quantity: 2,
      purchasePrice: 180000,
      purchaseDate: "2025-02-20",
      targetPrice: 200000,
    ),
  ];

  // 자산 배분 데이터
  List<AssetAllocation> get _assetAllocation {
    Map<String, double> sectorMap = {};
    
    for (var item in _portfolioItems) {
      final value = item.stock.price * item.quantity;
      final sector = _getSectorForStock(item.stock.name);
      
      if (sectorMap.containsKey(sector)) {
        sectorMap[sector] = sectorMap[sector]! + value;
      } else {
        sectorMap[sector] = value;
      }
    }
    
    final totalValue = _totalValue;
    List<AssetAllocation> result = [];
    
    sectorMap.forEach((sector, value) {
      final percentage = (value / totalValue) * 100;
      result.add(AssetAllocation(sector: sector, value: value, percentage: percentage));
    });
    
    // 비중이 큰 순서대로 정렬
    result.sort((a, b) => b.value.compareTo(a.value));
    
    return result;
  }

  // 종목별 섹터 반환 (실제 구현에서는 API에서 가져와야 함)
  String _getSectorForStock(String stockName) {
    final Map<String, String> sectorMap = {
      "삼성전자": "IT/전자",
      "SK하이닉스": "IT/전자",
      "NAVER": "서비스/통신",
      "카카오": "서비스/통신",
      "현대차": "자동차",
    };
    
    return sectorMap[stockName] ?? "기타";
  }

  // 포트폴리오 성과 데이터 (실제 구현에서는 API에서 가져와야 함)
  List<FlSpot> get _performanceData {
    return [
      const FlSpot(0, 100),
      const FlSpot(1, 102),
      const FlSpot(2, 98),
      const FlSpot(3, 104),
      const FlSpot(4, 105),
      const FlSpot(5, 108),
      const FlSpot(6, 107),
      const FlSpot(7, 110),
      const FlSpot(8, 112),
      const FlSpot(9, 115),
      const FlSpot(10, 113),
      const FlSpot(11, 118),
      const FlSpot(12, 120),
    ];
  }

  double get _totalInvestment {
    return _portfolioItems.fold(0, (sum, item) => sum + (item.purchasePrice * item.quantity));
  }

  double get _totalValue {
    return _portfolioItems.fold(0, (sum, item) => sum + (item.stock.price * item.quantity));
  }

  double get _totalReturn {
    return _totalValue - _totalInvestment;
  }

  double get _totalReturnPercentage {
    return (_totalReturn / _totalInvestment) * 100;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "포트폴리오",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '거래 내역',
            onPressed: () {
              _showTransactionHistory();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStockDialog();
        },
        child: const Icon(Icons.add),
        tooltip: '종목 추가',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 실제 구현에서는 여기서 최신 데이터를 가져옴
          await Future.delayed(const Duration(milliseconds: 800));
          return Future.value();
        },
        child: _portfolioItems.isEmpty
            ? _buildEmptyState()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    
                    // 포트폴리오 성과 그래프
                    _buildPerformanceChart(),
                    const SizedBox(height: 24),
                    
                    // 자산 배분 차트
                    _buildAssetAllocationChart(),
                    const SizedBox(height: 24),
                    
                    // 보유 종목 리스트
                    Text(
                      "보유 종목",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _portfolioItems.length,
                      itemBuilder: (context, index) {
                        return _buildPortfolioItemCard(_portfolioItems[index]);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "포트폴리오가 비어있습니다",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "우측 하단의 + 버튼을 눌러 종목을 추가하세요",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddStockDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text("종목 추가하기"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 요약 카드 위젯
  Widget _buildSummaryCard() {
    final isPositiveReturn = _totalReturn >= 0;
    
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
              "포트폴리오 요약",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  "총 투자금액",
                  "${_formatCurrency(_totalInvestment)}원",
                ),
                _buildSummaryItem(
                  "현재 가치",
                  "${_formatCurrency(_totalValue)}원",
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  "총 수익",
                  "${isPositiveReturn ? '+' : ''}${_formatCurrency(_totalReturn)}원",
                  valueColor: isPositiveReturn ? AppColors.upColor : AppColors.downColor,
                ),
                _buildSummaryItem(
                  "수익률",
                  "${isPositiveReturn ? '+' : ''}${_totalReturnPercentage.toStringAsFixed(2)}%",
                  valueColor: isPositiveReturn ? AppColors.upColor : AppColors.downColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 요약 아이템 위젯
  Widget _buildSummaryItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // 포트폴리오 성과 차트
  Widget _buildPerformanceChart() {
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
              "포트폴리오 성과",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "최근 3개월",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = '1월';
                              break;
                            case 4:
                              text = '2월';
                              break;
                            case 8:
                              text = '3월';
                              break;
                            case 12:
                              text = '현재';
                              break;
                            default:
                              return Container();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: 12,
                  minY: 90,
                  maxY: 125,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _performanceData,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodButton("1개월", false),
                _buildPeriodButton("3개월", true),
                _buildPeriodButton("6개월", false),
                _buildPeriodButton("1년", false),
                _buildPeriodButton("전체", false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 기간 선택 버튼
  Widget _buildPeriodButton(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(text),
        selected: isSelected,
        onSelected: (selected) {
          // 실제 구현에서는 여기서 기간에 따른 데이터 변경
        },
      ),
    );
  }

  // 자산 배분 차트
  Widget _buildAssetAllocationChart() {
    final List<PieChartSectionData> sections = _assetAllocation.map((item) {
      final Color color = _getSectorColor(item.sector);
      return PieChartSectionData(
        color: color,
        value: item.percentage,
        title: '${item.percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

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
              "자산 배분",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // 파이 차트
                SizedBox(
                  height: 180,
                  width: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 범례
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _assetAllocation.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildLegendItem(
                          item.sector,
                          _getSectorColor(item.sector),
                          item.percentage,
                        ),
                      );
                    }).toList(),
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
  Widget _buildLegendItem(String label, Color color, double value) {
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
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          "${value.toStringAsFixed(1)}%",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 섹터별 색상
  Color _getSectorColor(String sector) {
    final Map<String, Color> colorMap = {
      "IT/전자": Colors.blue,
      "서비스/통신": Colors.purple,
      "자동차": Colors.green,
      "금융": Colors.orange,
      "에너지": Colors.red,
      "헬스케어": Colors.teal,
      "소비재": Colors.amber,
      "기타": Colors.grey,
    };
    
    return colorMap[sector] ?? Colors.grey;
  }

  // 포트폴리오 아이템 카드
  Widget _buildPortfolioItemCard(PortfolioItem item) {
    final currentValue = item.stock.price * item.quantity;
    final investmentValue = item.purchasePrice * item.quantity;
    final returnValue = currentValue - investmentValue;
    final returnPercentage = (returnValue / investmentValue) * 100;
    final isPositiveReturn = returnValue >= 0;
    
    // 목표가 달성 여부
    final hasTargetPrice = item.targetPrice != null && item.targetPrice! > 0;
    final targetReached = hasTargetPrice && item.stock.price >= item.targetPrice!;
    final targetPercentage = hasTargetPrice 
        ? ((item.stock.price / item.targetPrice!) * 100).clamp(0, 100)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // 실제 구현에서는 여기서 종목 상세 화면으로 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.stock.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: '편집',
                        onPressed: () {
                          _showEditStockDialog(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: '삭제',
                        onPressed: () {
                          _showDeleteConfirmation(item);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 현재가 및 변동률
              Row(
                children: [
                  Text(
                    "${_formatCurrency(item.stock.price)}원",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.stock.change >= 0 ? AppColors.upColor : AppColors.downColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${item.stock.change >= 0 ? '+' : ''}${item.stock.change}%",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 매수 정보 및 수익률
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "매수가: ${_formatCurrency(item.purchasePrice)}원",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "보유수량: ${item.quantity}주",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "매수일: ${item.purchaseDate}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "평가금액: ${_formatCurrency(currentValue)}원",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "수익: ${isPositiveReturn ? '+' : ''}${_formatCurrency(returnValue)}원",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isPositiveReturn ? AppColors.upColor : AppColors.downColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "수익률: ${isPositiveReturn ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isPositiveReturn ? AppColors.upColor : AppColors.downColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 목표가 진행 상태
              if (hasTargetPrice) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "목표가: ${_formatCurrency(item.targetPrice!)}원",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: targetReached ? AppColors.upColor : null,
                      ),
                    ),
                    const Spacer(),
                    if (targetReached)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.upColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "목표 달성!",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.upColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: targetPercentage / 100,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  color: targetReached ? AppColors.upColor : Theme.of(context).colorScheme.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 종목 추가 다이얼로그
  void _showAddStockDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController purchasePriceController = TextEditingController();
    final TextEditingController purchaseDateController = TextEditingController(
      text: DateTime.now().toString().substring(0, 10),
    );
    final TextEditingController targetPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("종목 추가"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "종목명"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "현재가"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "보유수량"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchasePriceController,
                  decoration: const InputDecoration(labelText: "매수가"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchaseDateController,
                  decoration: const InputDecoration(labelText: "매수일 (YYYY-MM-DD)"),
                ),
                TextField(
                  controller: targetPriceController,
                  decoration: const InputDecoration(labelText: "목표가 (선택사항)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                // 실제 구현에서는 여기서 입력값 검증 및 종목 추가
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("종목이 추가되었습니다.")),
                );
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  // 종목 편집 다이얼로그
  void _showEditStockDialog(PortfolioItem item) {
    final TextEditingController quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final TextEditingController purchasePriceController = TextEditingController(
      text: item.purchasePrice.toString(),
    );
    final TextEditingController purchaseDateController = TextEditingController(
      text: item.purchaseDate,
    );
    final TextEditingController targetPriceController = TextEditingController(
      text: item.targetPrice?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${item.stock.name} 편집"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "보유수량"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchasePriceController,
                  decoration: const InputDecoration(labelText: "매수가"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchaseDateController,
                  decoration: const InputDecoration(labelText: "매수일 (YYYY-MM-DD)"),
                ),
                TextField(
                  controller: targetPriceController,
                  decoration: const InputDecoration(labelText: "목표가 (선택사항)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                // 실제 구현에서는 여기서 입력값 검증 및 종목 정보 업데이트
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("종목 정보가 업데이트되었습니다.")),
                );
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  // 종목 삭제 확인 다이얼로그
  void _showDeleteConfirmation(PortfolioItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("종목 삭제"),
          content: Text("${item.stock.name}을(를) 포트폴리오에서 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                // 실제 구현에서는 여기서 종목 삭제
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("종목이 삭제되었습니다.")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  // 거래 내역 보기
  void _showTransactionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 드래그 핸들
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // 제목
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "거래 내역",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                
                // 거래 내역 리스트 (더미 데이터)
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildTransactionItem(
                        "삼성전자",
                        "매수",
                        5,
                        68000,
                        "2025-01-15",
                      ),
                      _buildTransactionItem(
                        "SK하이닉스",
                        "매수",
                        3,
                        135000,
                        "2025-02-03",
                      ),
                      _buildTransactionItem(
                        "삼성전자",
                        "매수",
                        5,
                        69000,
                        "2025-02-10",
                      ),
                      _buildTransactionItem(
                        "NAVER",
                        "매수",
                        3,
                        220000,
                        "2025-01-28",
                      ),
                      _buildTransactionItem(
                        "카카오",
                        "매수",
                        10,
                        60000,
                        "2025-02-10",
                      ),
                      _buildTransactionItem(
                        "SK하이닉스",
                        "매수",
                        2,
                        138000,
                        "2025-02-15",
                      ),
                      _buildTransactionItem(
                        "현대차",
                        "매수",
                        2,
                        180000,
                        "2025-02-20",
                      ),
                      _buildTransactionItem(
                        "카카오",
                        "매수",
                        5,
                        58000,
                        "2025-03-05",
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 거래 내역 아이템
  Widget _buildTransactionItem(
    String stockName,
    String type,
    int quantity,
    double price,
    String date,
  ) {
    final isPositive = type == "매수";
    final totalAmount = price * quantity;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 거래 유형 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPositive ? AppColors.upColor.withOpacity(0.1) : AppColors.downColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.add : Icons.remove,
                color: isPositive ? AppColors.upColor : AppColors.downColor,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 거래 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stockName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            // 거래 금액
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isPositive ? '+' : '-'}${_formatCurrency(totalAmount)}원",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isPositive ? AppColors.upColor : AppColors.downColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$quantity주 @ ${_formatCurrency(price)}원",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 숫자 포맷팅 (천 단위 콤마)
  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class PortfolioItem {
  final StockModel stock;
  final int quantity;
  final double purchasePrice;
  final String purchaseDate;
  final double? targetPrice;

  PortfolioItem({
    required this.stock,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    this.targetPrice,
  });
}

class AssetAllocation {
  final String sector;
  final double value;
  final double percentage;

  AssetAllocation({
    required this.sector,
    required this.value,
    required this.percentage,
  });
}
