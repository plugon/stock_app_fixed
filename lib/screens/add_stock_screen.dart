import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // 토스트 메시지 표시를 위한 패키지
import '../models/stock_model.dart'; // 주식 데이터 모델
import '../services/api_service.dart'; // API 서비스 클래스
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소 관리 패키지
import 'dart:convert'; // JSON 인코딩/디코딩 라이브러리

// 주식 검색 및 추가를 위한 화면 위젯 클래스
class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

// 커스텀 검색 버튼 위젯 클래스
class CustomSearchButton extends StatelessWidget {
  final VoidCallback onPressed; // 버튼 클릭 이벤트 콜백 함수

  // 생성자: 반드시 onPressed 콜백 함수를 받아야 함
  CustomSearchButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // 버튼 배경색 설정
        foregroundColor: Colors.white, // 아이콘 및 텍스트 색상 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 10픽셀 둥근 모서리 설정
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 버튼 내부 패딩 설정
      ),
      icon: const Icon(Icons.search, size: 24), // 검색 아이콘 표시
      label: const Text("검색"), // 버튼 텍스트
      onPressed: onPressed, // 버튼 클릭 시 실행할 콜백 함수
    );
  }
}

// 로컬 스토리지 서비스 클래스 - 관심종목 목록 저장 및 불러오기 기능 제공
class LocalStorageService {
  static const _keyWatchlist = 'watchlist'; // SharedPreferences에 저장할 키 값

  // 관심종목 목록을 로컬 저장소에 저장하는 메서드
  static Future<void> saveWatchlist(List<StockModel> watchlist) async {
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 획득
    final jsonString = jsonEncode(watchlist.map((stock) => stock.toJson()).toList()); // 주식 객체 리스트를 JSON 문자열로 변환
    await prefs.setString(_keyWatchlist, jsonString); // 키 값으로 JSON 문자열 저장
  }

  // 관심종목 목록을 로컬 저장소에서 불러오는 메서드
  static Future<List<StockModel>> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 획득
    final jsonString = prefs.getString(_keyWatchlist); // 저장된 JSON 문자열 가져오기
    if (jsonString != null) {
      final List<dynamic> data = jsonDecode(jsonString); // JSON 문자열을 리스트로 디코딩
      return data.map((item) => StockModel.fromJson(item)).toList(); // 각 항목을 StockModel 객체로 변환하여 리스트 반환
    }
    return []; // 저장된 데이터가 없을 경우 빈 리스트 반환
  }
}

// AddStockScreen의 상태 관리 클래스
class _AddStockScreenState extends State<AddStockScreen> {
  final TextEditingController _controller = TextEditingController(); // 검색어 입력 컨트롤러
  bool _isLoading = false; // 로딩 상태 플래그
  List<StockModel> _searchResults = []; // 검색 결과 목록
  final List<StockModel> _selectedStocks = []; // 선택된 주식 목록

  // 주식 검색 메서드
  void _searchStock(String stockName) async {
    if (stockName.isNotEmpty) { // 검색어가 비어있지 않을 경우만 검색 실행
      setState(() => _isLoading = true); // 로딩 상태 시작
      try {
        final stockDetailsList = await StockAPIService.searchStocks(stockName); // API를 통한 주식 검색
        setState(() {
          if (stockDetailsList.isEmpty) {
            Fluttertoast.showToast(msg: "검색된 종목이 없습니다."); // 검색 결과가 없을 때 토스트 메시지 표시
          } else {
            _searchResults.addAll(stockDetailsList); // 검색 결과를 목록에 추가
          }
          _isLoading = false; // 로딩 상태 종료
        });
        _controller.clear(); // 검색어 입력 필드 초기화
      } catch (e) {
        _showSnackBar("오류 발생: $e"); // 오류 발생 시 스낵바 표시
        setState(() => _isLoading = false); // 로딩 상태 종료
      }
    }
  }

  // 주식 선택 토글 메서드 - 선택/해제 처리
  void _toggleSelection(StockModel stock) {
    setState(() {
      if (_selectedStocks.contains(stock)) {
        _selectedStocks.remove(stock); // 이미 선택된 경우 목록에서 제거
      } else {
        _selectedStocks.add(stock); // 선택되지 않은 경우 목록에 추가
      }
    });
  }

  // 선택된 주식을 관심종목에 추가하는 메서드
  void _addSelectedStocks() async {
    // 관심종목 목록에 선택된 주식들을 저장
    await LocalStorageService.saveWatchlist(_selectedStocks);
    Navigator.pop(context, _selectedStocks); // 이전 화면으로 돌아가면서 선택된 주식 목록 전달
  }

  // 스낵바 메시지 표시 메서드
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심종목 추가'), // 앱바 타이틀
        actions: [
          IconButton(
            icon: const Icon(Icons.check), // 완료 아이콘
            onPressed: _addSelectedStocks, // 아이콘 클릭 시 선택된 주식 추가 메서드 호출
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 전체 패딩
        child: Column(
          children: [
            Row(
              children: [
                // 검색 텍스트 필드
                Expanded(
                  child: TextField(
                    controller: _controller, // 검색어 입력 컨트롤러 연결
                    decoration: const InputDecoration(
                      labelText: '종목명 입력', // 라벨 텍스트
                    ),
                    onSubmitted: _searchStock, // 엔터 키 입력 시 검색 실행
                  ),
                ),
                const SizedBox(width: 10), // 간격 조정을 위한 SizedBox
                // 검색 버튼
                CustomSearchButton(
                  onPressed: () {
                    // 검색 버튼 클릭 시 현재 입력된 텍스트로 검색 실행
                    _searchStock(_controller.text);
                  },
                ),

                const SizedBox(width: 10), // 간격 조정을 위한 SizedBox
                // 관심종목 추가 버튼
                ElevatedButton(
                  onPressed: _addSelectedStocks, // 버튼 클릭 시 선택된 주식 추가 메서드 호출
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 버튼 내부 패딩
                    backgroundColor: Colors.blue, // 배경색 설정
                    foregroundColor: Colors.white, // 텍스트 색상 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 8픽셀 둥근 모서리 설정
                    ),
                  ),
                  child: const Text('추가'), // 버튼 텍스트
                ),
              ],
            ),
            const SizedBox(height: 20), // 간격 조정을 위한 SizedBox
            // 검색 결과 리스트 표시 영역
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length, // 검색 결과 개수만큼 아이템 생성
                itemBuilder: (context, index) {
                  final stock = _searchResults[index]; // 현재 인덱스의 주식 정보
                  final isSelected = _selectedStocks.contains(stock); // 선택 여부 확인
                  return ListTile(
                    title: Text(stock.name), // 주식 이름 표시
                    subtitle: Text("현재가: ${stock.price}"), // 주식 가격 표시
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green) // 선택된 경우 체크 아이콘 표시
                        : const Icon(Icons.radio_button_unchecked), // 선택되지 않은 경우 빈 원형 아이콘 표시
                    onTap: () => _toggleSelection(stock), // 탭 시 선택/해제 토글
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}