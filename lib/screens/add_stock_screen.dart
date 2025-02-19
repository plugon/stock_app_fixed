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
      setState(() => _isLoading = true);

      try {
        final stockDetails = await StockAPIService.getStockDetails(stockName);
        setState(() => _isLoading = false);

        if (stockDetails.isNotEmpty) {
          final newStock = StockModel(
            name: stockName,
            price: stockDetails['price'],
            change: stockDetails['change'],
            volume: stockDetails['volume'],
          );
          Navigator.pop(context, newStock); // ✅ 관심종목 추가 후 대시보드로 이동
        } else {
          _showErrorSnackBar("해당 종목 정보를 가져올 수 없습니다.");
        }
      } catch (e) {
        _showErrorSnackBar("❌ 오류 발생: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관심종목 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
