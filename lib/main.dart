import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart'; // ✅ DashboardScreen 임포트 추가

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '증권 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(), // ✅ DashboardScreen 정상적으로 연결
    );
  }
}
