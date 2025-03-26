import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱 전체에서 사용되는 타이포그래피 스타일 정의
class AppTypography {
  // 기본 폰트 패밀리
  static final TextTheme textTheme = TextTheme(
    // 제목 스타일
    displayLarge: GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    displayMedium: GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    displaySmall: GoogleFonts.roboto(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    
    // 부제목 스타일
    headlineMedium: GoogleFonts.roboto(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    headlineSmall: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    
    // 본문 스타일
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    
    // 작은 텍스트 스타일
    labelLarge: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    labelMedium: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    labelSmall: GoogleFonts.roboto(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
  );
  
  // 한글 폰트 패밀리 (Noto Sans KR)
  static final TextTheme koreanTextTheme = TextTheme(
    // 제목 스타일
    displayLarge: GoogleFonts.notoSansKr(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    displayMedium: GoogleFonts.notoSansKr(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    displaySmall: GoogleFonts.notoSansKr(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    
    // 부제목 스타일
    headlineMedium: GoogleFonts.notoSansKr(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    headlineSmall: GoogleFonts.notoSansKr(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    
    // 본문 스타일
    bodyLarge: GoogleFonts.notoSansKr(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.notoSansKr(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.notoSansKr(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    
    // 작은 텍스트 스타일
    labelLarge: GoogleFonts.notoSansKr(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    labelMedium: GoogleFonts.notoSansKr(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    labelSmall: GoogleFonts.notoSansKr(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
  );
  
  // 주식 가격 변동 스타일 (상승)
  static TextStyle priceUp(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF26A69A)  // 라이트 모드: 청록색
          : const Color(0xFF4DB6AC),  // 다크 모드: 밝은 청록색
    );
  }
  
  // 주식 가격 변동 스타일 (하락)
  static TextStyle priceDown(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFEF5350)  // 라이트 모드: 빨간색
          : const Color(0xFFE57373),  // 다크 모드: 밝은 빨간색
    );
  }
  
  // 주식 가격 변동 스타일 (변동 없음)
  static TextStyle priceNeutral(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF757575)  // 라이트 모드: 회색
          : const Color(0xFFBDBDBD),  // 다크 모드: 밝은 회색
    );
  }
}
