import 'package:flutter/material.dart';

// 📌 AI 추천 종목 화면
// - 이 화면은 AI 추천 종목을 사용자에게 보여줌
// - 현재는 샘플 UI 상태로, 실제 AI 데이터를 추가하는 데 사용 가능
class AIRecommendationScreen extends StatelessWidget {
  const AIRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📌 상단 AppBar: 화면 제목 표시
      appBar: AppBar(
        title: const Text("AI 추천픽"), // 제목: "AI 추천픽"
      ),
      // 📌 화면 본문
      body: Center(
        // 📌 화면 가운데에 아이콘과 텍스트를 배치
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 📌 아이콘 표시 (스타일 추가)
            const Icon(Icons.auto_awesome, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20), // 아이콘과 텍스트 사이 간격
            // 📌 텍스트 표시
            const Text(
              "AI 기반 추천 종목을 여기에 표시", // 현재는 더미 텍스트
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
