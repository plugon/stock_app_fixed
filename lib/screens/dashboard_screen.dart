import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';
import 'stock_detail_screen.dart';
import 'add_stock_screen.dart';

// 📌 대시보드 화면
// - 관심종목 리스트를 보여주고 관리하는 메인 화면
// - 종목 추가, 삭제, 상세화면으로 이동 등의 기능 제공
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 📌 관심종목 데이터를 저장하는 리스트
  List<StockModel> watchlist = [];

  // 📌 데이터 로딩 상태를 나타내는 플래그
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 초기화 시 관심종목 데이터를 불러옴
    _loadWatchlist();
  }

  // 🔧 관심종목 데이터를 API에서 불러오는 함수
  Future<void> _loadWatchlist() async {
    setState(() => isLoading = true);
    try {
      // ✅ StockAPIService를 사용해 관심종목 데이터를 가져옴
      watchlist = await StockAPIService.getWatchlist(['삼성전자', '현대자동차', 'LG전자']);
    } catch (e) {
      // 데이터 로드 실패 시 오류 출력
      print("❌ 관심종목 불러오기 오류: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📌 상단 AppBar: 화면 제목과 스타일 설정
      appBar: AppBar(
        title: const Text(
          "📊 대시보드", // 화면 제목: "대시보드"
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // 제목을 중앙 정렬
        backgroundColor: Colors.white, // AppBar 배경색 설정
        elevation: 0, // 그림자 제거
      ),
      // 📌 본문 영역
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 스피너 표시
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔧 관심종목 타이틀과 아이콘
                  const Row(
                    children: [
                      Icon(Icons.push_pin, color: Colors.redAccent), // 아이콘
                      SizedBox(width: 8), // 아이콘과 텍스트 간격
                      Text(
                        "관심종목", // 타이틀 텍스트
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 관심종목 리스트를 보여주는 테이블
                  _buildStockTable(),
                ],
              ),
            ),
      // 🔧 플로팅 액션 버튼: 종목 추가 화면으로 이동
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // AddStockScreen에서 새 종목을 추가하고 결과를 받아옴
          final newStock = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStockScreen()),
          );
          if (newStock != null && newStock is StockModel) {
            // 새로 추가된 종목을 관심종목 리스트에 추가
            setState(() => watchlist.add(newStock));
          }
        },
        child: const Icon(Icons.add), // 플로팅 버튼 아이콘
        backgroundColor: Colors.blue, // 플로팅 버튼 배경색
      ),
      // 📌 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "관심종목"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "설정"),
        ],
      ),
    );
  }

  // 🔧 관심종목 테이블 구성 함수
  Widget _buildStockTable() {
    return Expanded(
      child: ListView.builder(
        // 관심종목 개수만큼 리스트 아이템 생성
        itemCount: watchlist.length,
        itemBuilder: (context, index) {
          final stock = watchlist[index];
          return GestureDetector(
            onTap: () {
              // 아이템 클릭 시 상세화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(stock: stock),
                ),
              );
            },
            child: Container(
              // 짝수 행과 홀수 행의 배경색 구분
              color: index.isEven ? Colors.white : Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 📌 종목명
                  Expanded(child: Text(stock.name, textAlign: TextAlign.center)),
                  // 📌 현재가
                  Expanded(child: Text("${stock.price} 원", textAlign: TextAlign.center)),
                  // 📌 등락률 (양수는 초록색, 음수는 빨간색)
                  Expanded(
                    child: Text(
                      "${stock.change}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: stock.change >= 0 ? Colors.green : Colors.red),
                    ),
                  ),
                  // 📌 거래량
                  Expanded(child: Text(stock.volume, textAlign: TextAlign.center)),
                  // 📌 삭제 버튼
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // 삭제 버튼 클릭 시 해당 종목 제거
                      setState(() => watchlist.removeAt(index));
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
