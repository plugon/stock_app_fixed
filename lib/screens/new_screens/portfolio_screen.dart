import 'package:flutter/material.dart';
import '../../models/stock_model.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final List<PortfolioItem> _portfolioItems = [
    PortfolioItem(
      stock: StockModel(
        name: "삼성전자",
        price: 72500,
        change: 2.3,
        volume: "3.2M",
      ),
      quantity: 10,
      purchasePrice: 68000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "SK하이닉스",
        price: 142000,
        change: 3.1,
        volume: "1.5M",
      ),
      quantity: 5,
      purchasePrice: 135000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "NAVER",
        price: 215000,
        change: 1.2,
        volume: "0.7M",
      ),
      quantity: 3,
      purchasePrice: 220000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "카카오",
        price: 56700,
        change: -1.5,
        volume: "1.1M",
      ),
      quantity: 15,
      purchasePrice: 60000,
    ),
    PortfolioItem(
      stock: StockModel(
        name: "현대차",
        price: 187500,
        change: 0.5,
        volume: "0.6M",
      ),
      quantity: 2,
      purchasePrice: 180000,
    ),
  ];

  double get _totalInvestment {
    return _portfolioItems.fold(0, (sum, item) => sum + (item.purchasePrice * item.quantity));
  }

  double get _totalValue {
    return _portfolioItems.fold(0, (sum, item) => sum + (item.stock.price * item.quantity));
  }

  double get _totalReturn {
    return _totalValue - _totalInvestment;
  }

  double get _totalReturnPercentage {
    return (_totalReturn / _totalInvestment) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "💼 포트폴리오",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              _showAddStockDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            const Text(
              "보유 종목",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _portfolioItems.isEmpty
                  ? const Center(
                      child: Text(
                        "보유 종목이 없습니다.\n우측 상단의 + 버튼을 눌러 종목을 추가하세요.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _portfolioItems.length,
                      itemBuilder: (context, index) {
                        return _buildPortfolioItemCard(_portfolioItems[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isPositiveReturn = _totalReturn >= 0;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "포트폴리오 요약",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem("총 투자금액", "${_formatCurrency(_totalInvestment)}원"),
                _buildSummaryItem("현재 가치", "${_formatCurrency(_totalValue)}원"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  "총 수익",
                  "${isPositiveReturn ? '+' : ''}${_formatCurrency(_totalReturn)}원",
                  valueColor: isPositiveReturn ? Colors.green : Colors.red,
                ),
                _buildSummaryItem(
                  "수익률",
                  "${isPositiveReturn ? '+' : ''}${_totalReturnPercentage.toStringAsFixed(2)}%",
                  valueColor: isPositiveReturn ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioItemCard(PortfolioItem item) {
    final currentValue = item.stock.price * item.quantity;
    final investmentValue = item.purchasePrice * item.quantity;
    final returnValue = currentValue - investmentValue;
    final returnPercentage = (returnValue / investmentValue) * 100;
    final isPositiveReturn = returnValue >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.stock.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    _showEditStockDialog(item);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "현재가: ${_formatCurrency(item.stock.price)}원",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "매수가: ${_formatCurrency(item.purchasePrice)}원",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "보유수량: ${item.quantity}주",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "평가금액: ${_formatCurrency(currentValue)}원",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "수익: ${isPositiveReturn ? '+' : ''}${_formatCurrency(returnValue)}원",
                      style: TextStyle(
                        fontSize: 14,
                        color: isPositiveReturn ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "수익률: ${isPositiveReturn ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 14,
                        color: isPositiveReturn ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStockDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController purchasePriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("종목 추가"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "종목명"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "현재가"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "보유수량"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchasePriceController,
                  decoration: const InputDecoration(labelText: "매수가"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                // 입력 값 검증 및 종목 추가 로직
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    purchasePriceController.text.isNotEmpty) {
                  setState(() {
                    _portfolioItems.add(
                      PortfolioItem(
                        stock: StockModel(
                          name: nameController.text,
                          price: double.parse(priceController.text),
                          change: 0.0, // 임시 값
                          volume: "0", // 임시 값
                        ),
                        quantity: int.parse(quantityController.text),
                        purchasePrice: double.parse(purchasePriceController.text),
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  void _showEditStockDialog(PortfolioItem item) {
    final TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
    final TextEditingController purchasePriceController = TextEditingController(text: item.purchasePrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${item.stock.name} 수정"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "보유수량"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchasePriceController,
                  decoration: const InputDecoration(labelText: "매수가"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                // 입력 값 검증 및 종목 수정 로직
                if (quantityController.text.isNotEmpty &&
                    purchasePriceController.text.isNotEmpty) {
                  setState(() {
                    item.quantity = int.parse(quantityController.text);
                    item.purchasePrice = double.parse(purchasePriceController.text);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("수정"),
            ),
            TextButton(
              onPressed: () {
                // 종목 삭제 로직
                setState(() {
                  _portfolioItems.remove(item);
                });
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(double value) {
    // 천 단위 구분자 추가
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class PortfolioItem {
  final StockModel stock;
  int quantity;
  double purchasePrice;

  PortfolioItem({
    required this.stock,
    required this.quantity,
    required this.purchasePrice,
  });
}
