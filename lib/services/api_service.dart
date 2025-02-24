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
  final String apiKey =
      "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D"; // 공공데이터포털 API 키
  final String url =
      "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo?serviceKey=$apiKey&numOfRows=1&pageNo=1&resultType=json&itmsNm=$stockName";

  // 요청 URL 출력
  print("디버그: 요청 URL -> $url");
print("디버그: 요청 stockName -> $stockName");
  try {
    final response = await http.get(Uri.parse(url));
    print("디버그: HTTP 응답 상태 코드 -> ${response.statusCode}");
    print("디버그: HTTP 응답 본문 -> ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("디버그: JSON 파싱 결과 -> $data");

      if (data["response"]["header"]["resultCode"] == "00") {
        final body = data["response"]["body"];

        // totalCount가 0이면 데이터가 없음을 의미
        if (body["totalCount"] == 0) {
          print("디버그: totalCount가 0입니다. 유효한 데이터가 없습니다.");
          return {};
        }

        final items = body["items"]["item"];
        if (items == null) {
          print("디버그: items가 null입니다.");
          return {};
        }

        dynamic item;
        if (items is List) {
          if (items.isEmpty) {
            print("디버그: items 리스트가 비어 있습니다.");
            return {};
          }
          item = items[0];
        } else if (items is Map) {
          // 단일 아이템 객체로 올 경우 처리
          item = items;
        } else {
          print("디버그: items의 타입이 예상과 다릅니다: ${items.runtimeType}");
          return {};
        }

        // 각 필드를 안전하게 파싱
        final price = double.tryParse(item["clpr"]?.toString() ?? "0") ?? 0.0;
        final change = double.tryParse(item["vs"]?.toString() ?? "0") ?? 0.0;
        final volume = item["trqu"]?.toString() ?? "0";

        // 차트용 데이터는 더미로 7일치 가격을 생성
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
      } else {
        print("디버그: API 응답 코드가 '00'이 아님 -> ${data["response"]["header"]["resultCode"]}");
      }
    } else {
      print("디버그: HTTP 요청 실패 -> 상태 코드: ${response.statusCode}");
    }
  } catch (e) {
    print("디버그: 공공데이터포털 API 호출 중 예외 발생 -> $e");
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
