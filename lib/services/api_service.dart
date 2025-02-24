import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StockAPI { YahooFinance, PublicDataPortal, IEXCloud }

// 현재 사용할 API를 선택 (기본 PublicDataPortal)
const StockAPI currentAPI = StockAPI.PublicDataPortal;

class StockAPIService {
  /// 관심종목 저장 및 불러오기 기능 추가
  static const String _storageKey = 'watchlist';

  static Future<void> saveWatchlist(List<StockModel> watchlist) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(watchlist.map((stock) => stock.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  static Future<List<StockModel>> getStoredWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final data = jsonDecode(jsonString) as List;
      return data.map((item) => StockModel.fromJson(item)).toList();
    }
    return [];
  }

  /// 🔧 검색된 종목 리스트 반환
  static Future<List<StockModel>> searchStocks(String query) async {
    final String apiKey = "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D";
    final String baseUrl = "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo";

    final String url = "$baseUrl?serviceKey=$apiKey&numOfRows=1&pageNo=1&resultType=json&itmsNm=$query";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data["response"]["body"]["items"]["item"] ?? [];

        // 'items'가 리스트인지 확인하고 변환
        return items.map<StockModel>((item) {
          return StockModel(
            name: item["itmsNm"] ?? "",
            price: double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0,
            change: double.tryParse(item["vs"]?.toString() ?? "0") ?? 0.0,
            volume: item["trqu"]?.toString() ?? "0",
          );
        }).toList();
      } else {
        print("API 응답 에러: 상태 코드 ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("API 호출 중 오류: $e");
      return [];
    }
  }

  /// 관심종목 데이터 가져오기
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

  /// 종목 상세 데이터 가져오기
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

  /// Public Data Portal 종목 상세 데이터
  static Future<Map<String, dynamic>> _fetchPublicDataPortalStockDetails(String stockName) async {
    final String apiKey = "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D";
    final String url =
        "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo?serviceKey=$apiKey&numOfRows=1&pageNo=1&resultType=json&itmsNm=$stockName";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["response"]["header"]["resultCode"] == "00") {
          final body = data["response"]["body"];
          if (body["totalCount"] == 0) {
            return {};
          }

          final items = body["items"]["item"];
          dynamic item = items is List ? items[0] : items;

          final price = double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0;
          final change = double.tryParse(item["vs"]?.toString() ?? "0") ?? 0.0;
          final volume = item["trqu"]?.toString() ?? "0";

          final historicalPrices = List<double>.generate(
            7,
            (index) => double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0,
          );

          return {
            'price': price,
            'change': change,
            'volume': volume,
            'historicalPrices': historicalPrices,
          };
        }
      }
    } catch (e) {
      print("공공데이터포털 API 오류: $e");
    }
    return {};
  }

  /// Yahoo Finance API
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
          'historicalPrices': List<double>.from([72.0, 73.5, 74.2, 72.8, 75.3]),
        };
      }
    } catch (e) {
      print("Yahoo Finance API 오류: $e");
    }
    return {};
  }

  /// IEX Cloud API
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
          'historicalPrices': List<double>.from([75.0, 76.5, 74.8, 77.2]),
        };
      }
    } catch (e) {
      print("IEX Cloud API 오류: $e");
    }
    return {};
  }
}
