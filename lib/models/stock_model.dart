class StockModel {
  // 종목 이름 (예: 삼성전자)
  final String name;
  
  // 현재 가격 (예: 56000)
  final double price;

  // 등락률 (예: 0.3% 상승이면 0.3, 0.5% 하락이면 -0.5)
  final double change;

  // 거래량 (예: "1.2M" 또는 "900K")
  final String volume;

  // 생성자: 모델 인스턴스를 초기화
  StockModel({
    required this.name,
    required this.price,
    required this.change,
    required this.volume,
  });

  // 데이터를 JSON 형식으로 변환
  // 주로 네트워크 전송이나 로컬 저장 시 사용
  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'change': change,
        'volume': volume,
      };

  // JSON 데이터를 StockModel 인스턴스로 변환
  // API에서 받아온 데이터를 모델로 쉽게 처리할 수 있음
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      name: json['name'], // JSON에서 'name' 키에 해당하는 값을 name에 저장
      price: (json['price'] ?? 0).toDouble(), // JSON에서 'price' 키에 해당하는 값을 price에 저장
      change: (json['change'] ?? 0).toDouble(), // JSON에서 'change' 키에 해당하는 값을 change에 저장
      volume: json['volume'] ?? "0", // JSON에서 'volume' 키에 해당하는 값을 volume에 저장
    );
  }
}
