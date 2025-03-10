class StockModel {
  final String name; // 📌 종목명 (예: "삼성전자")
  final double price; // 📌 현재가 (예: 56000.0)
  final double change; // 📌 등락률 (예: 1.5%)
  final String volume; // 📌 거래량 (예: "1.2M")

  // 📌 StockModel 생성자: 각 필드에 값 할당
  StockModel({
    required this.name,
    required this.price,
    required this.change,
    required this.volume,
  });

  // 📌 객체를 JSON 형태로 변환 (서버로 전송하거나 로컬 저장 시 사용)
  Map<String, dynamic> toJson() => {
        'name': name, // 종목명
        'price': price, // 현재가
        'change': change, // 등락률
        'volume': volume, // 거래량
      };

  // 📌 JSON 데이터를 StockModel 객체로 변환 (서버 응답 처리 시 사용)
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      name: json['name'], // JSON에서 'name' 키 값 추출
      price: (json['price'] ?? 0).toDouble(), // JSON에서 'price' 키 값 추출, 없으면 0.0
      change: (json['change'] ?? 0).toDouble(), // JSON에서 'change' 키 값 추출, 없으면 0.0
      volume: json['volume'] ?? "0", // JSON에서 'volume' 키 값 추출, 없으면 "0"
    );
  }
}
