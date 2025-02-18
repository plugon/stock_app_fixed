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

  void _addStock(String stockName) async {
    if (stockName.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // ✅ API에서 최신 주가 가져오기
      final stockPrice = await StockAPIService.getStockPrice(stockName);

      setState(() {
        _isLoading = false;
      });

      if (stockPrice != null) {
        final newStock = StockModel(name: stockName, price: stockPrice);
        Navigator.pop(context, newStock); // ✅ 관심종목 추가 후 대시보드로 이동
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("해당 종목 정보를 가져올 수 없습니다.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('관심종목 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '종목명 입력',
                suffixIcon: _isLoading
                    ? CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addStock(_controller.text),
                      ),
              ),
            ),
            SizedBox(height: 20),
            Text('추천 종목'),
            Expanded(
              child: ListView.builder(
                itemCount: _sampleStocks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_sampleStocks[index]),
                    onTap: () => _addStock(_sampleStocks[index]),
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
