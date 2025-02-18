import 'package:flutter/material.dart';
import '../models/stock_model.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<StockModel> watchlist = [
    StockModel(name: "삼성전자", price: 56000, change: 0.3, volume: "1.2M"),
    StockModel(name: "현대자동차", price: 210000, change: -0.8, volume: "900K"),
    StockModel(name: "LG전자", price: 79400, change: 1.5, volume: "750K"),
  ];

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
      body: Padding(
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
        onPressed: () {
          // 관심종목 추가 화면 이동
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey[200],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("📌 종목명", textAlign: TextAlign.center)),
              Expanded(child: Text("💰 현재가", textAlign: TextAlign.center)),
              Expanded(child: Text("📊 등락률", textAlign: TextAlign.center)),
              Expanded(child: Text("📈 거래량", textAlign: TextAlign.center)),
              SizedBox(width: 40),
            ],
          ),
        ),
        Column(
          children: watchlist.asMap().entries.map((entry) {
            int index = entry.key;
            StockModel stock = entry.value;
            return Container(
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
                      setState(() {
                        watchlist.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
