import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';
import 'stock_detail_screen.dart';
import 'add_stock_screen.dart';
import '../theme/app_colors.dart';

// 대시보드 화면: 관심종목 리스트를 관리하고 저장하는 메인 화면
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  // 관심종목 데이터를 저장하는 리스트
  List<StockModel> watchlist = [];
  
  // 데이터 로딩 상태를 나타내는 플래그
  bool isLoading = true;
  
  // 시장 상황 요약 데이터
  Map<String, dynamic> marketSummary = {
    'kospi': {'value': 3150.48, 'change': 0.75},
    'kosdaq': {'value': 932.15, 'change': 1.25},
    'nasdaq': {'value': 16320.35, 'change': -0.32},
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 화면 초기화 시 관심종목 데이터를 로컬 저장소에서 불러옴
    _loadWatchlist();
  }

  // 로컬 저장소에서 관심종목 데이터를 로드하는 함수
  Future<void> _loadWatchlist() async {
    setState(() => isLoading = true); // 로딩 상태 활성화
    try {
      watchlist = await StockAPIService.getStoredWatchlist(); // 로컬 저장소에서 데이터 가져오기
    } catch (e) {
      // 로드 실패 시 로그 출력
      print("❌ 관심종목 불러오기 오류: $e");
    }
    setState(() => isLoading = false); // 로딩 상태 비활성화
  }

  // 관심종목 리스트를 업데이트하고 저장하는 함수
  void _updateWatchlist(List<StockModel> newStocks) async {
    // 기존 관심종목에 새로 추가된 종목들을 합침
    setState(() => watchlist = [...watchlist, ...newStocks]);
    // 변경된 관심종목을 로컬 저장소에 저장
    await StockAPIService.saveWatchlist(watchlist);
  }

  // 관심종목 순서 변경 함수
  void _reorderWatchlist(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final StockModel item = watchlist.removeAt(oldIndex);
      watchlist.insert(newIndex, item);
    });
    // 변경된 관심종목을 로컬 저장소에 저장
    await StockAPIService.saveWatchlist(watchlist);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // 상단 AppBar: 화면 제목 및 스타일
      appBar: AppBar(
        title: const Text(
          "대시보드",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWatchlist,
            tooltip: '새로고침',
          ),
        ],
      ),
      // 본문 영역
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 스피너 표시
          : RefreshIndicator(
              onRefresh: _loadWatchlist,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시장 상황 요약 카드
                    _buildMarketSummaryCard(context),
                    const SizedBox(height: 24),
                    
                    // 관심종목 섹션 타이틀
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, 
                              color: isDarkMode ? AppColors.primary : AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              "관심종목",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        // 관심종목 개수 표시
                        Text(
                          "${watchlist.length}개",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 관심종목이 없을 때 안내 메시지
                    if (watchlist.isEmpty)
                      _buildEmptyWatchlistMessage(context)
                    else
                      // 관심종목 리스트 테이블
                      _buildStockTable(context),
                  ],
                ),
              ),
            ),
      // 플로팅 액션 버튼: 종목 추가 화면으로 이동
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // AddStockScreen 화면에서 새 종목 리스트를 받아옴
          final newStocks = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStockScreen()),
          );
          // 새로 추가된 종목이 있을 경우 관심종목 리스트 업데이트
          if (newStocks != null && newStocks is List<StockModel>) {
            _updateWatchlist(newStocks);
          }
        },
        tooltip: '종목 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 시장 상황 요약 카드 위젯
  Widget _buildMarketSummaryCard(BuildContext context) {
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
              "시장 동향",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarketIndexItem(context, "KOSPI", marketSummary['kospi']['value'], 
                  marketSummary['kospi']['change']),
                _buildMarketIndexItem(context, "KOSDAQ", marketSummary['kosdaq']['value'], 
                  marketSummary['kosdaq']['change']),
                _buildMarketIndexItem(context, "NASDAQ", marketSummary['nasdaq']['value'], 
                  marketSummary['nasdaq']['change']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 시장 지수 아이템 위젯
  Widget _buildMarketIndexItem(BuildContext context, String name, double value, double change) {
    final isPositive = change >= 0;
    final color = isPositive ? AppColors.upColor : AppColors.downColor;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            Text(
              "${change.abs().toStringAsFixed(2)}%",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 관심종목이 없을 때 표시할 메시지 위젯
  Widget _buildEmptyWatchlistMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.star_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "관심종목이 없습니다",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "우측 하단의 + 버튼을 눌러 관심종목을 추가해보세요",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 관심종목 테이블 생성 함수
  Widget _buildStockTable(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // 테이블 헤더
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    const SizedBox(width: 48), // 삭제 버튼 공간
                  ],
                ),
              ),
              
              // 구분선
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).dividerTheme.color,
              ),
              
              // 관심종목 리스트
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: watchlist.length,
                onReorder: _reorderWatchlist,
                itemBuilder: (context, index) {
                  final stock = watchlist[index];
                  final isPositive = stock.change >= 0;
                  final changeColor = isPositive ? AppColors.upColor : AppColors.downColor;
                  
                  return InkWell(
                    key: ValueKey(stock.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailScreen(stock: stock),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          // 종목명
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                const Icon(Icons.drag_handle, size: 16, color: AppColors.neutral),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    stock.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: changeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${stock.change.abs().toStringAsFixed(2)}%",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: changeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          
                          // 삭제 버튼
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () async {
                              setState(() => watchlist.removeAt(index));
                              await StockAPIService.saveWatchlist(watchlist);
                            },
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
      ),
    );
  }
}
