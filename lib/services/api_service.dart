import 'dart:convert';
import 'package:http/http.dart' as http;
import '../stock_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용 가능한 주식 API 종류를 정의하는 열거형
enum StockAPI { yahooFinance, publicDataPortal, iexCloud }

/// API 키 관리 클래스
class ApiKeys {
  // 공공데이터포털 API 키 (기본값)
  static String publicDataPortalKey = "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D";
  
  // Yahoo Finance API 키
  static String yahooFinanceKey = "";
  
  // IEX Cloud API 키
  static String iexCloudKey = "";
  
  // API 키 저장
  static Future<void> saveApiKey(StockAPI api, String key) async {
    final prefs = await SharedPreferences.getInstance();
    String keyName;
    
    switch (api) {
      case StockAPI.publicDataPortal:
        keyName = 'public_data_portal_key';
        publicDataPortalKey = key;
        break;
      case StockAPI.yahooFinance:
        keyName = 'yahoo_finance_key';
        yahooFinanceKey = key;
        break;
      case StockAPI.iexCloud:
        keyName = 'iex_cloud_key';
        iexCloudKey = key;
        break;
    }
    
    await prefs.setString(keyName, key);
  }
  
  // API 키 로드
  static Future<void> loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    
    publicDataPortalKey = prefs.getString('public_data_portal_key') ?? publicDataPortalKey;
    yahooFinanceKey = prefs.getString('yahoo_finance_key') ?? yahooFinanceKey;
    iexCloudKey = prefs.getString('iex_cloud_key') ?? iexCloudKey;
  }
}

/// API 설정 관리 클래스
class ApiSettings {
  // 현재 사용 중인 API
  static StockAPI currentAPI = StockAPI.publicDataPortal;
  
  // 실시간 데이터 사용 여부
  static bool useRealTimeData = true;
  
  // 데이터 갱신 주기 (분 단위, 0은 실시간)
  static int refreshInterval = 1;
  
  // 설정 저장
  static Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_api', currentAPI.index);
    await prefs.setBool('use_real_time_data', useRealTimeData);
    await prefs.setInt('refresh_interval', refreshInterval);
  }
  
  // 설정 로드
  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final apiIndex = prefs.getInt('current_api');
    if (apiIndex != null && apiIndex < StockAPI.values.length) {
      currentAPI = StockAPI.values[apiIndex];
    }
    
    useRealTimeData = prefs.getBool('use_real_time_data') ?? true;
    refreshInterval = prefs.getInt('refresh_interval') ?? 1;
  }
}

/// 주식 API 관련 서비스를 제공하는 클래스
class StockApiService {
  // 싱글톤 인스턴스
  static final StockApiService _instance = StockApiService._internal();
  
  // 팩토리 생성자
  factory StockApiService() {
    return _instance;
  }
  
  // 내부 생성자
  StockApiService._internal();
  
  // 초기화 메서드
  static Future<void> initialize() async {
    await ApiKeys.loadApiKeys();
    await ApiSettings.loadSettings();
  }

  /// 관심종목 저장 및 불러오기를 위한 SharedPreferences 키 값
  static const String _storageKey = 'watchlist';

  /// 관심종목 목록을 로컬 저장소에 저장하는 메서드
  static Future<void> saveWatchlist(List<StockModel> watchlist) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(watchlist.map((stock) => stock.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// 로컬 저장소에서 관심종목 목록을 불러오는 메서드
  static Future<List<StockModel>> getStoredWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final data = jsonDecode(jsonString) as List;
      return data.map((item) => StockModel.fromJson(item)).toList();
    }
    return [];
  }

  /// 주식 종목을 이름으로 검색하여 목록을 반환하는 메서드
  static Future<List<StockModel>> searchStocks(String query) async {
    // 검색어가 비어있으면 빈 리스트 반환
    if (query.isEmpty) {
      return [];
    }
    
    // 현재 설정된 API에 따라 다른 메서드 호출
    switch (ApiSettings.currentAPI) {
      case StockAPI.yahooFinance:
        return _searchYahooFinanceStocks(query);
      case StockAPI.publicDataPortal:
        return _searchPublicDataPortalStocks(query);
      case StockAPI.iexCloud:
        return _searchIEXCloudStocks(query);
      default:
        return [];
    }
  }
  
  /// 공공데이터포털 API를 사용하여 종목 검색
  static Future<List<StockModel>> _searchPublicDataPortalStocks(String query) async {
    // 공공데이터포털 주식 정보 API 기본 URL
    final String baseUrl = "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo";
    
    // 검색 쿼리를 포함한 API 요청 URL 생성
    final String url = "$baseUrl?serviceKey=${ApiKeys.publicDataPortalKey}&numOfRows=20&pageNo=1&resultType=json&likeItmsNm=$query";

    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 응답 코드가 성공(00)인 경우에만 처리
        if (data["response"]["header"]["resultCode"] == "00") {
          final body = data["response"]["body"];
          if (body["totalCount"] == 0) {
            return [];
          }
          
          final items = body["items"]["item"];
          
          // 결과가 단일 항목인 경우 리스트로 변환
          final itemsList = items is List ? items : [items];
          
          // 결과를 StockModel 객체 리스트로 변환
          return itemsList.map<StockModel>((item) {
            return StockModel(
              name: item["itmsNm"] ?? "",
              price: double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0,
              change: double.tryParse(item["vs"]?.toString() ?? "0") ?? 0.0,
              volume: item["trqu"]?.toString() ?? "0",
            );
          }).toList();
        }
      }
    } catch (e) {
      print("공공데이터포털 API 검색 오류: $e");
    }
    
    return [];
  }
  
  /// Yahoo Finance API를 사용하여 종목 검색
  static Future<List<StockModel>> _searchYahooFinanceStocks(String query) async {
    // 실제 구현에서는 Yahoo Finance API 호출
    // 현재는 더미 데이터 반환
    return [
      StockModel(
        name: "삼성전자",
        price: 72500,
        change: 2.3,
        volume: "3.2M",
      ),
      StockModel(
        name: "SK하이닉스",
        price: 142000,
        change: 3.1,
        volume: "1.5M",
      ),
    ];
  }
  
  /// IEX Cloud API를 사용하여 종목 검색
  static Future<List<StockModel>> _searchIEXCloudStocks(String query) async {
    // 실제 구현에서는 IEX Cloud API 호출
    // 현재는 더미 데이터 반환
    return [
      StockModel(
        name: "AAPL",
        price: 172.5,
        change: 1.2,
        volume: "45.6M",
      ),
      StockModel(
        name: "MSFT",
        price: 342.8,
        change: 0.8,
        volume: "22.3M",
      ),
    ];
  }

  /// 관심종목 데이터를 가져오는 메서드
  static Future<List<StockModel>> getWatchlist(List<String> stockNames) async {
    List<StockModel> watchlist = [];
    
    // 실시간 데이터를 사용하지 않는 경우 저장된 데이터 반환
    if (!ApiSettings.useRealTimeData) {
      return getStoredWatchlist();
    }
    
    // 각 종목에 대해 상세 정보를 가져와서 StockModel 객체로 변환
    for (String stockName in stockNames) {
      try {
        final details = await getStockDetails(stockName);
        if (details.isNotEmpty) {
          watchlist.add(StockModel(
            name: stockName,
            price: details['price'],
            change: details['change'],
            volume: details['volume'],
          ));
        }
      } catch (e) {
        print("관심종목 데이터 로드 오류: $e");
      }
    }
    
    return watchlist;
  }

  /// 종목 상세 데이터를 가져오는 메서드 - 설정된 API에 따라 적절한 메서드 호출
  static Future<Map<String, dynamic>> getStockDetails(String stockName) async {
    // 현재 설정된 API에 따라 다른 메서드 호출
    switch (ApiSettings.currentAPI) {
      case StockAPI.yahooFinance:
        return _fetchYahooFinanceStockDetails(stockName);
      case StockAPI.publicDataPortal:
        return _fetchPublicDataPortalStockDetails(stockName);
      case StockAPI.iexCloud:
        return _fetchIEXCloudStockDetails(stockName);
      default:
        return {};
    }
  }

  /// 공공데이터포털 API를 사용하여 종목 상세 데이터를 가져오는 메서드
  static Future<Map<String, dynamic>> _fetchPublicDataPortalStockDetails(String stockName) async {
    // API 요청 URL 생성 - 정확한 종목명으로 검색
    final String url =
        "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo?serviceKey=${ApiKeys.publicDataPortalKey}&numOfRows=1&pageNo=1&resultType=json&itmsNm=$stockName";

    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 응답 코드가 성공(00)인 경우에만 처리
        if (data["response"]["header"]["resultCode"] == "00") {
          final body = data["response"]["body"];
          if (body["totalCount"] == 0) {
            return {};
          }

          // 검색 결과 아이템 추출
          final items = body["items"]["item"];
          // 결과가 배열인 경우 첫 번째 항목, 아니면 그대로 사용
          dynamic item = items is List ? items[0] : items;

          // 필요한 데이터 추출 및 변환
          final price = double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0;
          final change = double.tryParse(item["vs"]?.toString() ?? "0") ?? 0.0;
          final volume = item["trqu"]?.toString() ?? "0";
          
          // 추가 정보 추출 (있는 경우)
          final high = double.tryParse(item["hipr"]?.toString() ?? "0") ?? 0.0;
          final low = double.tryParse(item["lopr"]?.toString() ?? "0") ?? 0.0;
          final open = double.tryParse(item["mkp"]?.toString() ?? "0") ?? 0.0;
          final date = item["basDt"]?.toString() ?? "";

          // 임시로 7일간의 가격 데이터 생성 (실제로는 히스토리 API 호출 필요)
          // 약간의 변동성을 추가하여 더 현실적인 차트 데이터 생성
          final random = DateTime.now().millisecondsSinceEpoch % 10;
          final historicalPrices = List<double>.generate(
            7,
            (index) => price * (1 + (random - 5 + index) / 100),
          );

          // 추출한 데이터를 맵으로 반환
          return {
            'price': price,
            'change': change,
            'volume': volume,
            'high': high,
            'low': low,
            'open': open,
            'date': date,
            'historicalPrices': historicalPrices,
          };
        }
      }
    } catch (e) {
      print("공공데이터포털 API 오류: $e");
    }
    
    return {};
  }

  /// Yahoo Finance API를 사용하여 종목 상세 데이터를 가져오는 메서드
  static Future<Map<String, dynamic>> _fetchYahooFinanceStockDetails(String stockName) async {
    // Yahoo Finance API URL
    final String url = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=$stockName";
    
    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // 응답 데이터에서 첫 번째 결과 추출
        final data = jsonDecode(response.body)["quoteResponse"]["result"][0];
        // 필요한 데이터를 맵으로 반환
        return {
          'price': data["regularMarketPrice"] ?? 0.0,
          'change': data["regularMarketChangePercent"] ?? 0.0,
          'volume': data["regularMarketVolume"]?.toString() ?? "0",
          'high': data["regularMarketDayHigh"] ?? 0.0,
          'low': data["regularMarketDayLow"] ?? 0.0,
          'open': data["regularMarketOpen"] ?? 0.0,
          'historicalPrices': List<double>.from([72.0, 73.5, 74.2, 72.8, 75.3]),
        };
      }
    } catch (e) {
      print("Yahoo Finance API 오류: $e");
    }
    
    return {};
  }

  /// IEX Cloud API를 사용하여 종목 상세 데이터를 가져오는 메서드
  static Future<Map<String, dynamic>> _fetchIEXCloudStockDetails(String stockName) async {
    // IEX Cloud API URL
    final String url = "https://cloud.iexapis.com/stable/stock/$stockName/quote?token=${ApiKeys.iexCloudKey}";

    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 필요한 데이터를 맵으로 반환
        return {
          'price': data["latestPrice"] ?? 0.0,
          'change': data["changePercent"] ?? 0.0,
          'volume': data["latestVolume"]?.toString() ?? "0",
          'high': data["high"] ?? 0.0,
          'low': data["low"] ?? 0.0,
          'open': data["open"] ?? 0.0,
          'historicalPrices': List<double>.from([75.0, 76.5, 74.8, 77.2]),
        };
      }
    } catch (e) {
      print("IEX Cloud API 오류: $e");
    }
    
    return {};
  }
  
  /// 뉴스 데이터를 가져오는 메서드
  static Future<List<Map<String, dynamic>>> getNewsForStock(String stockName) async {
    // 실제 구현에서는 뉴스 API 호출
    // 현재는 더미 데이터 반환
    return [
      {
        'title': '$stockName, 분기 실적 예상치 상회',
        'summary': '$stockName이 최근 발표한 분기 실적이 시장 예상치를 크게 상회하며 주가 상승.',
        'source': '경제신문',
        'date': '2025-03-15',
        'url': 'https://example.com/news/1',
        'imageUrl': 'https://via.placeholder.com/150',
      },
      {
        'title': '$stockName, 신제품 출시 계획 발표',
        'summary': '$stockName이 다음 달 신제품 출시 계획을 발표하며 업계의 관심이 집중되고 있음.',
        'source': '테크뉴스',
        'date': '2025-03-14',
        'url': 'https://example.com/news/2',
        'imageUrl': 'https://via.placeholder.com/150',
      },
      {
        'title': '애널리스트, $stockName에 대한 투자의견 상향 조정',
        'summary': '주요 증권사들이 $stockName에 대한 투자의견을 매수로 상향 조정하며 목표가 역시 상향.',
        'source': '투자정보',
        'date': '2025-03-12',
        'url': 'https://example.com/news/3',
        'imageUrl': 'https://via.placeholder.com/150',
      },
    ];
  }
  
  /// 시장 지수 데이터를 가져오는 메서드
  static Future<List<Map<String, dynamic>>> getMarketIndices() async {
    // 실제 구현에서는 시장 지수 API 호출
    // 현재는 더미 데이터 반환
    return [
      {
        'name': 'KOSPI',
        'value': 2650.23,
        'change': 1.2,
        'historicalData': [2630.45, 2635.78, 2642.12, 2638.56, 2645.89, 2650.23],
      },
      {
        'name': 'KOSDAQ',
        'value': 850.67,
        'change': 0.8,
        'historicalData': [845.32, 848.56, 852.45, 849.78, 847.92, 850.67],
      },
      {
        'name': 'S&P 500',
        'value': 4780.45,
        'change': -0.3,
        'historicalData': [4795.23, 4790.45, 4785.67, 4782.34, 4778.90, 4780.45],
      },
      {
        'name': 'NASDAQ',
        'value': 15980.34,
        'change': -0.5,
        'historicalData': [16050.23, 16030.45, 16010.67, 15995.34, 15985.90, 15980.34],
      },
    ];
  }
  
  /// 업종별 성과 데이터를 가져오는 메서드
  static Future<List<Map<String, dynamic>>> getSectorPerformance() async {
    // 실제 구현에서는 업종별 성과 API 호출
    // 현재는 더미 데이터 반환
    return [
      {
        'name': 'IT/전자',
        'change': 2.5,
        'marketCap': 5482,
      },
      {
        'name': '금융',
        'change': 1.2,
        'marketCap': 3245,
      },
      {
        'name': '제약/바이오',
        'change': 3.1,
        'marketCap': 2876,
      },
      {
        'name': '자동차',
        'change': -0.8,
        'marketCap': 2345,
      },
      {
        'name': '화학',
        'change': -1.2,
        'marketCap': 1987,
      },
      {
        'name': '철강',
        'change': 0.5,
        'marketCap': 1654,
      },
      {
        'name': '유통',
        'change': 1.8,
        'marketCap': 1432,
      },
      {
        'name': '건설',
        'change': -0.3,
        'marketCap': 1234,
      },
    ];
  }
  
  /// 인기 종목 데이터를 가져오는 메서드
  static Future<List<StockModel>> getHotStocks() async {
    // 실제 구현에서는 인기 종목 API 호출
    // 현재는 더미 데이터 반환
    return [
      StockModel(
        name: "삼성전자",
        price: 72500,
        change: 2.3,
        volume: "3.2M",
      ),
      StockModel(
        name: "SK하이닉스",
        price: 142000,
        change: 3.1,
        volume: "1.5M",
      ),
      StockModel(
        name: "NAVER",
        price: 215000,
        change: 1.2,
        volume: "0.7M",
      ),
      StockModel(
        name: "카카오",
        price: 56700,
        change: -1.5,
        volume: "1.1M",
      ),
      StockModel(
        name: "현대차",
        price: 187500,
        change: 0.5,
        volume: "0.6M",
      ),
    ];
  }
  
  /// QR 코드로 종목 정보를 가져오는 메서드
  static Future<StockModel?> getStockFromQRCode(String qrData) async {
    // QR 코드 데이터 파싱
    try {
      // QR 코드 형식: "STOCK:종목명:종목코드"
      if (qrData.startsWith("STOCK:")) {
        final parts = qrData.split(":");
        if (parts.length >= 3) {
          final stockName = parts[1];
          final stockCode = parts[2];
          
          // 종목 정보 가져오기
          final details = await getStockDetails(stockName);
          if (details.isNotEmpty) {
            return StockModel(
              name: stockName,
              price: details['price'],
              change: details['change'],
              volume: details['volume'],
            );
          }
        }
      }
    } catch (e) {
      print("QR 코드 처리 오류: $e");
    }
    
    return null;
  }
}
