import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/stock_model.dart';

class LocalStorage {
  static const String _key = 'watchlist';

  // 관심 종목 저장 (List<StockModel>)
  static Future<void> saveWatchlist(List<StockModel> watchlist) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(watchlist.map((e) => e.toJson()).toList());
    prefs.setString(_key, jsonString);
  }

  // 관심 종목 불러오기 (List<StockModel>)
  static Future<List<StockModel>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => StockModel.fromJson(e)).toList();
  }
}
