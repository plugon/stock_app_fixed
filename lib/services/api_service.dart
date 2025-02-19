import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';

enum StockAPI { YahooFinance, PublicDataPortal, IEXCloud }

// ✅ 현재 사용할 API를 선택 (공공데이터포털을 기본으로 사용)
const StockAPI currentAPI = StockAPI.PublicDataPortal;

class StockAPIService {
  /// ✅ 관심종목의 최신 주가 및 데이터 가져오기
  static Future<List<StockModel>> getWatchlist(List<String> stockNames) async {
    List<StockModel> watchlist = [];
    for (String stockName in stockNames) {
      final details = await getStockDetails(stockName);
      watchlist.add(StockModel(
        name: stockName,
        price: details['price'],
        change: details['change'],
        volume: details['volume'],
      ));
    }
    return watchlist;
  }

  /// ✅ 종목 상세 데이터 (가격, 거래량, 등락률, 차트용 데이터) 가져오기
  static Future<Map<String, dynamic>> getStockDetails(String stockName) async {
    switch (currentAPI) {
      case StockAPI.YahooFinance:
        return _fetchYahooFinanceStockDetails(stockName);
      case StockAPI.PublicDataPortal:
        return _fetchPublicDataPortalStockDetails(stockName);
      case StockAPI.IEXCloud:
        return _fetchIEXCloudStockDetails(stockName);
      default:
        return {};
    }
  }

  /// ✅ 공공데이터포털 API - 종목 상세 데이터
  static Future<Map<String, dynamic>> _fetchPublicDataPortalStockDetails(String stockName) async {
    final String apiKey = "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D"; // ✅ 공공데이터포털 API 키 입력
    final String url ="https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo?serviceKey=$apiKey&numOfRows=1&pageNo=1&resultType=json&itmsNm=$stockName";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["response"]["header"]["resultCode"] == "00") {
          final item = data["response"]["body"]["items"]["item"][0];
          return {
            'price': double.tryParse(item["clpr"] ?? "0") ?? 0.0,
            'change': double.tryParse(item["vs"] ?? "0") ?? 0.0,
            'volume': item["trqu"] ?? "0",
            'historicalPrices': List<double>.generate(
                7, (index) => double.tryParse(item["clpr"]) ?? 0.0), // 더미 차트 데이터
          };
        }
      }
    } catch (e) {
      print("❌ 공공데이터포털 API 오류: $e");
    }
    return {};
  }

  /// ✅ Yahoo Finance API - 종목 상세 데이터
  static Future<Map<String, dynamic>> _fetchYahooFinanceStockDetails(String stockName) async {
    final String url = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=$stockName";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["quoteResponse"]["result"][0];
        return {
          'price': data["regularMarketPrice"] ?? 0.0,
          'change': data["regularMarketChangePercent"] ?? 0.0,
          'volume': data["regularMarketVolume"]?.toString() ?? "0",
          'historicalPrices': List<double>.from([72.0, 73.5, 74.2, 72.8, 75.3]), // 예시 차트 데이터
        };
      }
    } catch (e) {
      print("❌ Yahoo Finance API 오류: $e");
    }
    return {};
  }

  /// ✅ IEX Cloud API - 종목 상세 데이터
  static Future<Map<String, dynamic>> _fetchIEXCloudStockDetails(String stockName) async {
    final String apiKey = "YOUR_IEX_CLOUD_API_KEY";
    final String url = "https://cloud.iexapis.com/stable/stock/$stockName/quote?token=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'price': data["latestPrice"] ?? 0.0,
          'change': data["changePercent"] ?? 0.0,
          'volume': data["latestVolume"]?.toString() ?? "0",
          'historicalPrices': List<double>.from([75.0, 76.5, 74.8, 77.2]), // 예시 차트 데이터
        };
      }
    } catch (e) {
      print("❌ IEX Cloud API 오류: $e");
    }
    return {};
  }
}
