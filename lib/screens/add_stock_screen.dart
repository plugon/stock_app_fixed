import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';

// ✅ 관심종목 추가 화면
class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final TextEditingController _controller = TextEditingController(); // 검색창 입력 컨트롤러
  final List<String> _sampleStocks = ['삼성전자', '현대자동차', '네이버', '카카오', 'LG전자']; // 추천 종목 리스트
  bool _isLoading = false; // 데이터 로딩 상태를 나타내는 변수

  // 현재 추가된 종목들을 저장하는 리스트
  final List<StockModel> _addedStocks = [];

  // 🔧 종목 추가 함수
  // - 사용자가 종목명을 검색창에 입력하거나 추천 종목을 선택했을 때 호출
  // - 중복 추가를 방지하고, 추가된 종목 목록을 화면에 업데이트
  void _addStock(String stockName) async {
    if (stockName.isNotEmpty) {
      setState(() {
        _isLoading = true; // 로딩 상태 활성화
      });

      try {
        // ✅ 종목 상세 데이터 가져오기 (가격, 변동률, 거래량)
        final stockDetails = await StockAPIService.getStockDetails(stockName);
        setState(() {
          _isLoading = false; // 로딩 상태 비활성화
        });

        if (stockDetails.isNotEmpty) {
          final newStock = StockModel(
            name: stockName,
            price: stockDetails['price'],
            change: stockDetails['change'],
            volume: stockDetails['volume'],
          );
          // 중복 추가 방지: 이미 추가된 종목인지 확인
          bool alreadyAdded = _addedStocks.any((stock) => stock.name == newStock.name);
          if (!alreadyAdded) {
            // 중복되지 않았다면 추가
            setState(() {
              _addedStocks.add(newStock);
            });
            _showSnackBar("[$stockName] 종목이 추가되었습니다.");
            _controller.clear(); // 입력창 비우기
          } else {
            _showSnackBar("[$stockName] 종목은 이미 추가되었습니다.");
          }
        } else {
          _showSnackBar("해당 종목 정보를 가져올 수 없습니다.");
        }
      } catch (e) {
        // API 호출 중 오류 발생 시 처리
        _showSnackBar("오류 발생: $e");
        setState(() {
          _isLoading = false; // 로딩 상태 비활성화
        });
      }
    }
  }

  // 🔧 스낵바를 통해 사용자에게 메시지 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심종목 추가'), // 화면 제목
        actions: [
          // ✅ 완료 버튼: 추가된 종목들을 반환하고 화면 종료
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _addedStocks); // 추가한 종목 목록 반환
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 검색창
            // 사용자가 종목명을 입력할 수 있는 텍스트 필드
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '종목명 입력',
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(), // 로딩 표시
                      )
                    : IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addStock(_controller.text), // 종목 추가 호출
                      ),
              ),
              onSubmitted: _addStock,
            ),
            const SizedBox(height: 20),

            // ✅ 추가된 종목 목록
            if (_addedStocks.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추가된 종목', // 섹션 제목
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // ListView.builder를 사용하여 추가된 종목을 리스트로 표시
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                    itemCount: _addedStocks.length,
                    itemBuilder: (context, index) {
                      final stock = _addedStocks[index];
                      return ListTile(
                        title: Text(stock.name), // 종목명 표시
                        subtitle: Text('가격: ${stock.price}'), // 가격 표시
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _addedStocks.removeAt(index); // 종목 삭제
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // ✅ 추천 종목 섹션
            // 사용자가 추천 종목을 빠르게 추가할 수 있도록 표시
            const Text('📈 추천 종목'),
            Expanded(
              child: ListView.builder(
                itemCount: _sampleStocks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_sampleStocks[index]), // 추천 종목명 표시
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      onTap: () => _addStock(_sampleStocks[index]), // 종목 추가 호출
                    ),
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
