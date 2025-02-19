import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/api_service.dart';
import 'stock_detail_screen.dart';
import 'add_stock_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<StockModel> watchlist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() => isLoading = true);
    try {
      watchlist = await StockAPIService.getWatchlist(['삼성전자', '현대자동차', 'LG전자']);
    } catch (e) {
      print("❌ 관심종목 불러오기 오류: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📊 대시보드",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.push_pin, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text(
                        "관심종목",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildStockTable(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newStock = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStockScreen()),
          );
          if (newStock != null && newStock is StockModel) {
            setState(() => watchlist.add(newStock));
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "관심종목"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "설정"),
        ],
      ),
    );
  }

  Widget _buildStockTable() {
    return Expanded(
      child: ListView.builder(
        itemCount: watchlist.length,
        itemBuilder: (context, index) {
          final stock = watchlist[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(stock: stock),
                ),
              );
            },
            child: Container(
              color: index.isEven ? Colors.white : Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(stock.name, textAlign: TextAlign.center)),
                  Expanded(child: Text("${stock.price} 원", textAlign: TextAlign.center)),
                  Expanded(
                    child: Text(
                      "${stock.change}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: stock.change >= 0 ? Colors.green : Colors.red),
                    ),
                  ),
                  Expanded(child: Text(stock.volume, textAlign: TextAlign.center)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
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
