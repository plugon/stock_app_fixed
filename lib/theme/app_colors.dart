import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 테마 정의
class AppColors {
  // 주요 색상
  static const Color primary = Color(0xFF1E88E5); // 기본 색상: 파란색 - 신뢰성과 안정감
  static const Color upColor = Color(0xFF26A69A); // 상승장 표시: 청록색
  static const Color downColor = Color(0xFFEF5350); // 하락장 표시: 빨간색
  static const Color neutral = Color(0xFF757575); // 일반 텍스트: 회색
  
  // 배경 색상
  static const Color backgroundLight = Color(0xFFF5F5F5); // 라이트 모드 배경
  static const Color backgroundDark = Color(0xFF121212); // 다크 모드 배경
  
  // 카드 색상
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // 텍스트 색상
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  
  // 아이콘 색상
  static const Color iconLight = Color(0xFF616161);
  static const Color iconDark = Color(0xFFBDBDBD);
  
  // 구분선 색상
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  
  // 버튼 색상
  static const Color buttonLight = primary;
  static const Color buttonDark = primary;
  
  // 그림자 색상
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x1AFFFFFF);
  
  // 차트 색상
  static const List<Color> chartColors = [
    Color(0xFF1E88E5), // 파란색
    Color(0xFF26A69A), // 청록색
    Color(0xFFFFB300), // 노란색
    Color(0xFF7E57C2), // 보라색
    Color(0xFFEF5350), // 빨간색
    Color(0xFF66BB6A), // 초록색
  ];
}
