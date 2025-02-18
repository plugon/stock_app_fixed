import 'dart:convert';
import 'package:http/http.dart' as http;

enum StockAPI { YahooFinance, PublicDataPortal, IEXCloud }

// ✅ 현재 사용할 API를 선택 (공공데이터포털을 기본으로 사용)
const StockAPI currentAPI = StockAPI.PublicDataPortal;

class StockAPIService {
  // ✅ 관심종목의 최신 주가 가져오기
  static Future<double?> getStockPrice(String stockName) async {
    switch (currentAPI) {
      case StockAPI.YahooFinance:
        return _fetchYahooFinanceStockPrice(stockName);
      case StockAPI.PublicDataPortal:
        return _fetchPublicDataPortalStockPrice(stockName);
      case StockAPI.IEXCloud:
        return _fetchIEXCloudStockPrice(stockName);
      default:
        return null;
    }
  }

  // ✅ 공공데이터포털 API에서 최신 주가 가져오기
  static Future<double?> _fetchPublicDataPortalStockPrice(String stockName) async {
    final String apiKey = "L5xHJjuog46hJGCvOxg8vjW6MN2sT%2F%2BMFJq2YNFtNg%2B2iznFpL9%2BZMuIXSMoikW2S3wnlf6lPYQlC2SFrt9smQ%3D%3D"; // ✅ 공공데이터포털 API 키 입력
    final String url = "https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo"
        "?serviceKey=$apiKey"
        "&numOfRows=1"
        "&pageNo=1"
        "&resultType=json"
        "&itmsNm=$stockName"; // ✅ 종목명으로 검색

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["response"]["header"]["resultCode"] == "00") {
          final List<dynamic> items = data["response"]["body"]["items"]["item"];
          if (items.isNotEmpty) {
            return double.tryParse(items[0]["clpr"] ?? "0"); // ✅ 종가(clpr) 가져오기
          }
        }
      }
    } catch (e) {
      print("❌ 공공데이터포털 API 오류: $e");
    }
    return null;
  }

  // ✅ Yahoo Finance API에서 최신 주가 가져오기
  static Future<double?> _fetchYahooFinanceStockPrice(String stockName) async {
    final String url = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=$stockName";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["quoteResponse"]["result"][0]["regularMarketPrice"];
      }
    } catch (e) {
      print("❌ Yahoo Finance API 오류: $e");
    }
    return null;
  }

  // ✅ IEX Cloud API에서 최신 주가 가져오기
  static Future<double?> _fetchIEXCloudStockPrice(String stockName) async {
    final String apiKey = "YOUR_IEX_CLOUD_API_KEY"; // ✅ IEX Cloud API 키 입력
    final String url = "https://cloud.iexapis.com/stable/stock/$stockName/quote?token=$apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["latestPrice"];
      }
    } catch (e) {
      print("❌ IEX Cloud API 오류: $e");
    }
    return null;
  }
}
