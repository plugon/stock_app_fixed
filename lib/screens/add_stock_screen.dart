import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';

class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class CustomSearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  CustomSearchButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // 버튼 배경색
        foregroundColor: Colors.white, // 아이콘 및 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 둥근 모서리
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 패딩
      ),
      icon: const Icon(Icons.search, size: 24),
      label: const Text("검색"),
      onPressed: onPressed,
    );
  }
}

class _AddStockScreenState extends State<AddStockScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<StockModel> _searchResults = [];
  final List<StockModel> _selectedStocks = [];

  void _searchStock(String stockName) async {
    if (stockName.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final stockDetailsList = await StockAPIService.searchStocks(stockName);
        setState(() {
          if (stockDetailsList.isEmpty) {
            Fluttertoast.showToast(msg: "검색된 종목이 없습니다.");
          } else {
            _searchResults.addAll(stockDetailsList);
          }
          _isLoading = false;
        });
        _controller.clear(); // 검색어 초기화
      } catch (e) {
        _showSnackBar("오류 발생: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSelection(StockModel stock) {
    setState(() {
      if (_selectedStocks.contains(stock)) {
        _selectedStocks.remove(stock);
      } else {
        _selectedStocks.add(stock);
      }
    });
  }

  void _addSelectedStocks() {
    Navigator.pop(context, _selectedStocks);
  }

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
            onPressed: _addSelectedStocks,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // 검색 텍스트 필드
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '종목명 입력',
                    ),
                    onSubmitted: _searchStock,
                  ),
                ),
                const SizedBox(width: 10),
                // 검색 버튼
                CustomSearchButton(
                        onPressed: () {
                          // 검색 로직
                          _searchStock(_controller.text);
                        },
                ),

      
                const SizedBox(width: 10),
                // 관심종목 추가 버튼
                ElevatedButton(
                  onPressed: _addSelectedStocks,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    backgroundColor: Colors.blue, // 배경색
                    foregroundColor: Colors.white, // 텍스트 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('추가'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 검색 결과 리스트
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final stock = _searchResults[index];
                  final isSelected = _selectedStocks.contains(stock);
                  return ListTile(
                    title: Text(stock.name),
                    subtitle: Text("현재가: ${stock.price}"),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: () => _toggleSelection(stock),
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
