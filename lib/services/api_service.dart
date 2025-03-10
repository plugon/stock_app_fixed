import 'dart:convert'; // JSON 인코딩/디코딩을 위한 라이브러리
import 'package:http/http.dart' as http; // HTTP 통신을 위한 패키지
import '../models/stock_model.dart'; // 주식 모델 클래스
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소 관리 패키지

// 사용 가능한 주식 API 종류를 정의하는 열거형
enum StockAPI { YahooFinance, PublicDataPortal, IEXCloud }

// 현재 사용할 API를 선택 (기본값으로 PublicDataPortal 설정)
const StockAPI currentAPI = StockAPI.PublicDataPortal;

// 주식 API 관련 서비스를 제공하는 클래스
class StockAPIService {
  /// 관심종목 저장 및 불러오기를 위한 SharedPreferences 키 값
  static const String _storageKey = 'watchlist';

  /// 관심종목 목록을 로컬 저장소에 저장하는 메서드
  static Future<void> saveWatchlist(List<StockModel> watchlist) async {
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 획득
    final jsonString = jsonEncode(watchlist.map((stock) => stock.toJson()).toList()); // 주식 객체 리스트를 JSON 문자열로 변환
    await prefs.setString(_storageKey, jsonString); // 키 값으로 JSON 문자열 저장
  }

  /// 로컬 저장소에서 관심종목 목록을 불러오는 메서드
  static Future<List<StockModel>> getStoredWatchlist() async {
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 획득
    final jsonString = prefs.getString(_storageKey); // 저장된 JSON 문자열 가져오기
    if (jsonString != null) {
      final data = jsonDecode(jsonString) as List; // JSON 문자열을 리스트로 디코딩
      return data.map((item) => StockModel.fromJson(item)).toList(); // 각 항목을 StockModel 객체로 변환하여 리스트 반환
    }
    return []; // 저장된 데이터가 없을 경우 빈 리스트 반환
  }

  /// 🔧 주식 종목을 이름으로 검색하여 목록을 반환하는 메서드
  static Future<List<StockModel>> searchStocks(String query) async {
    // 공공데이터포털 API 키 설정
    final String apiKey = "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D";
    // 공공데이터포털 주식 정보 API 기본 URL
    final String baseUrl = "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo";

    // 검색 쿼리를 포함한 API 요청 URL 생성
    final String url = "$baseUrl?serviceKey=$apiKey&numOfRows=1&pageNo=1&resultType=json&likeItmsNm=$query";

    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) { // 요청 성공 시
        final data = jsonDecode(response.body); // 응답 데이터 JSON 파싱
        final items = data["response"]["body"]["items"]["item"] ?? []; // items 배열 추출 (없으면 빈 배열)

        // items를 StockModel 객체 리스트로 변환하여 반환
        return items.map<StockModel>((item) {
          return StockModel(
            name: item["itmsNm"] ?? "", // 종목명 (없으면 빈 문자열)
            price: double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0, // 종가 (변환 실패 시 0.0)
            change: double.tryParse(item["vs"]?.toString() ?? "0") ?? 0.0, // 전일 대비 변동 (변환 실패 시 0.0)
            volume: item["trqu"]?.toString() ?? "0", // 거래량 (없으면 "0")
          );
        }).toList();
      } else {
        print("API 응답 에러: 상태 코드 ${response.statusCode}"); // 오류 로그
        return []; // 빈 리스트 반환
      }
    } catch (e) {
      print("API 호출 중 오류: $e"); // 예외 발생 로그
      return []; // 빈 리스트 반환
    }
  }

  /// 관심종목 데이터를 가져오는 메서드
  static Future<List<StockModel>> getWatchlist(List<String> stockNames) async {
    List<StockModel> watchlist = []; // 결과를 저장할 빈 리스트
    // 각 종목에 대해 상세 정보를 가져와서 StockModel 객체로 변환
    for (String stockName in stockNames) {
      final details = await getStockDetails(stockName); // 종목 상세 정보 요청
      watchlist.add(StockModel(
        name: stockName, // 종목명
        price: details['price'], // 가격
        change: details['change'], // 변동
        volume: details['volume'], // 거래량
      ));
    }
    return watchlist; // 완성된 관심종목 리스트 반환
  }

  /// 종목 상세 데이터를 가져오는 메서드 - 설정된 API에 따라 적절한 메서드 호출
  static Future<Map<String, dynamic>> getStockDetails(String stockName) async {
    // 현재 설정된 API에 따라 다른 메서드 호출
    switch (currentAPI) {
      case StockAPI.YahooFinance:
        return _fetchYahooFinanceStockDetails(stockName); // Yahoo Finance API 사용
      case StockAPI.PublicDataPortal:
        return _fetchPublicDataPortalStockDetails(stockName); // 공공데이터포털 API 사용
      case StockAPI.IEXCloud:
        return _fetchIEXCloudStockDetails(stockName); // IEX Cloud API 사용
      default:
        return {}; // 기본값: 빈 맵 반환
    }
  }

  /// 공공데이터포털 API를 사용하여 종목 상세 데이터를 가져오는 메서드
  static Future<Map<String, dynamic>> _fetchPublicDataPortalStockDetails(String stockName) async {
    // 공공데이터포털 API 키
    final String apiKey = "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D";
    // API 요청 URL 생성 - 정확한 종목명으로 검색
    final String url =
        "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo?serviceKey=$apiKey&numOfRows=1&pageNo=1&resultType=json&itmsNm=$stockName";

    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) { // 요청 성공 시
        final data = jsonDecode(response.body); // 응답 데이터 JSON 파싱

        // 응답 코드가 성공(00)인 경우에만 처리
        if (data["response"]["header"]["resultCode"] == "00") {
          final body = data["response"]["body"];
          if (body["totalCount"] == 0) { // 검색 결과가 없는 경우
            return {}; // 빈 맵 반환
          }

          // 검색 결과 아이템 추출
          final items = body["items"]["item"];
          // 결과가 배열인 경우 첫 번째 항목, 아니면 그대로 사용
          dynamic item = items is List ? items[0] : items;

          // 필요한 데이터 추출 및 변환
          final price = double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0; // 종가
          final change = double.tryParse(item["vs"]?.toString() ?? "0") ?? 0.0; // 변동
          final volume = item["trqu"]?.toString() ?? "0"; // 거래량

          // 임시로 7일간의 동일한 가격 데이터 생성 (실제로는 히스토리 API 호출 필요)
          final historicalPrices = List<double>.generate(
            7,
            (index) => double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0,
          );

          // 추출한 데이터를 맵으로 반환
          return {
            'price': price,
            'change': change,
            'volume': volume,
            'historicalPrices': historicalPrices,
          };
        }
      }
    } catch (e) {
      print("공공데이터포털 API 오류: $e"); // 예외 발생 로그
    }
    return {}; // 오류 발생 시 빈 맵 반환
  }

  /// Yahoo Finance API를 사용하여 종목 상세 데이터를 가져오는 메서드
  static Future<Map<String, dynamic>> _fetchYahooFinanceStockDetails(String stockName) async {
    // Yahoo Finance API URL
    final String url = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=$stockName";
    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) { // 요청 성공 시
        // 응답 데이터에서 첫 번째 결과 추출
        final data = jsonDecode(response.body)["quoteResponse"]["result"][0];
        // 필요한 데이터를 맵으로 반환
        return {
          'price': data["regularMarketPrice"] ?? 0.0, // 현재가
          'change': data["regularMarketChangePercent"] ?? 0.0, // 변동률
          'volume': data["regularMarketVolume"]?.toString() ?? "0", // 거래량
          'historicalPrices': List<double>.from([72.0, 73.5, 74.2, 72.8, 75.3]), // 임시 히스토리 데이터
        };
      }
    } catch (e) {
      print("Yahoo Finance API 오류: $e"); // 예외 발생 로그
    }
    return {}; // 오류 발생 시 빈 맵 반환
  }

  /// IEX Cloud API를 사용하여 종목 상세 데이터를 가져오는 메서드
  static Future<Map<String, dynamic>> _fetchIEXCloudStockDetails(String stockName) async {
    // IEX Cloud API 키 (실제 키로 교체 필요)
    final String apiKey = "YOUR_IEX_CLOUD_API_KEY";
    // IEX Cloud API URL
    final String url = "https://cloud.iexapis.com/stable/stock/$stockName/quote?token=$apiKey";

    try {
      // HTTP GET 요청 전송
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) { // 요청 성공 시
        final data = jsonDecode(response.body); // 응답 데이터 JSON 파싱
        // 필요한 데이터를 맵으로 반환
        return {
          'price': data["latestPrice"] ?? 0.0, // 최신 가격
          'change': data["changePercent"] ?? 0.0, // 변동률
          'volume': data["latestVolume"]?.toString() ?? "0", // 거래량
          'historicalPrices': List<double>.from([75.0, 76.5, 74.8, 77.2]), // 임시 히스토리 데이터
        };
      }
    } catch (e) {
      print("IEX Cloud API 오류: $e"); // 예외 발생 로그
    }
    return {}; // 오류 발생 시 빈 맵 반환
  }
}