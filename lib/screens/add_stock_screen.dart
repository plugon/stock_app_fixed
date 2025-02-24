import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';

class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _sampleStocks = ['삼성전자', '현대자동차', '네이버', '카카오', 'LG전자'];
  bool _isLoading = false;

  // 추가된 종목들을 저장하는 리스트
  final List<StockModel> _addedStocks = [];

  // 종목 추가 함수 (검색창 또는 추천 종목 탭 시 호출)
  void _addStock(String stockName) async {
    if (stockName.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final stockDetails = await StockAPIService.getStockDetails(stockName);
        setState(() {
          _isLoading = false;
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
            setState(() {
              _addedStocks.add(newStock);
            });
            _showSnackBar("[$stockName] 종목이 추가되었습니다.");
            _controller.clear();
          } else {
            _showSnackBar("[$stockName] 종목은 이미 추가되었습니다.");
          }
        } else {
          _showSnackBar("해당 종목 정보를 가져올 수 없습니다.");
        }
      } catch (e) {
        _showSnackBar("오류 발생: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 스낵바를 통해 메시지 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심종목 추가'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // 완료 버튼 클릭 시 추가한 종목 목록을 반환
              Navigator.pop(context, _addedStocks);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색창
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '종목명 입력',
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addStock(_controller.text),
                      ),
              ),
              onSubmitted: _addStock,
            ),
            const SizedBox(height: 20),
            // 추가된 종목 목록 (있을 경우)
            if (_addedStocks.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추가된 종목',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _addedStocks.length,
                    itemBuilder: (context, index) {
                      final stock = _addedStocks[index];
                      return ListTile(
                        title: Text(stock.name),
                        subtitle: Text('가격: ${stock.price}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _addedStocks.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            // 추천 종목은 항상 하단에 표시
            const Text('📈 추천 종목'),
            Expanded(
              child: ListView.builder(
                itemCount: _sampleStocks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_sampleStocks[index]),
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      onTap: () => _addStock(_sampleStocks[index]),
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
