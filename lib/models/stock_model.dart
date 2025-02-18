class StockModel {
  final String name;
  final double price;
  final double change; // 📌 등락률 추가
  final String volume; // 📌 거래량 추가

  StockModel({
    required this.name,
    required this.price,
    required this.change,
    required this.volume,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'change': change,
        'volume': volume,
      };

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      name: json['name'],
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(), // 등락률 추가
      volume: json['volume'] ?? "0", // 거래량 추가
    );
  }
}
