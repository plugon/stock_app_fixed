import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';
import 'stock_detail_screen.dart';
import 'add_stock_screen.dart';

// 🔧 대시보드 화면: 관심종목 리스트를 관리하고 저장하는 메인 화면
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 🔧 관심종목 데이터를 저장하는 리스트
  List<StockModel> watchlist = [];
  
  // 🔧 데이터 로딩 상태를 나타내는 플래그
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 화면 초기화 시 관심종목 데이터를 로컬 저장소에서 불러옴
    _loadWatchlist();
  }

  // 🔧 로컬 저장소에서 관심종목 데이터를 로드하는 함수
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

  // 🔧 관심종목 리스트를 업데이트하고 저장하는 함수
  void _updateWatchlist(List<StockModel> newStocks) async {
    // 기존 관심종목에 새로 추가된 종목들을 합침
    setState(() => watchlist = [...watchlist, ...newStocks]);
    // 변경된 관심종목을 로컬 저장소에 저장
    await StockAPIService.saveWatchlist(watchlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔧 상단 AppBar: 화면 제목 및 스타일
      appBar: AppBar(
        title: const Text(
          "📊 대시보드", // 화면 제목
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // 제목 중앙 정렬
        backgroundColor: Colors.white, // AppBar 배경색
        elevation: 0, // 그림자 제거
      ),
      // 🔧 본문 영역
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 스피너 표시
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 관심종목 섹션 타이틀
                  const Row(
                    children: [
                      Icon(Icons.push_pin, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text(
                        "관심종목", // 섹션 이름
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 관심종목 리스트 테이블
                  _buildStockTable(),
                ],
              ),
            ),
      // 🔧 플로팅 액션 버튼: 종목 추가 화면으로 이동
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
        child: const Icon(Icons.add), // 플로팅 버튼 아이콘
        backgroundColor: Colors.blue, // 플로팅 버튼 배경색
      ),
      // 🔧 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "관심종목"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "설정"),
        ],
      ),
    );
  }

  // 🔧 관심종목 테이블 생성 함수
  Widget _buildStockTable() {
    return Expanded(
      child: ListView.builder(
        // 관심종목 개수만큼 리스트 아이템 생성
        itemCount: watchlist.length,
        itemBuilder: (context, index) {
          final stock = watchlist[index];
          return GestureDetector(
            // 관심종목 클릭 시 상세화면으로 이동
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(stock: stock),
                ),
              );
            },
            // 관심종목 리스트 각 행 디자인
            child: Container(
              color: index.isEven ? Colors.white : Colors.grey[100], // 짝수/홀수 행 배경색 구분
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(stock.name, textAlign: TextAlign.center)), // 종목명
                  Expanded(child: Text("${stock.price} 원", textAlign: TextAlign.center)), // 현재가
                  Expanded(
                    child: Text(
                      "${stock.change}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: stock.change >= 0 ? Colors.green : Colors.red),
                    ),
                  ), // 등락률
                  Expanded(child: Text(stock.volume, textAlign: TextAlign.center)), // 거래량
                  // 삭제 버튼: 클릭 시 해당 종목 삭제 후 로컬 저장소 업데이트
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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
    );
  }
}
