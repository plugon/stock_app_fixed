import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/new_screens/news_screen.dart';
import 'screens/new_screens/market_screen.dart';
import 'screens/new_screens/portfolio_screen.dart';
import 'screens/new_screens/settings_screen.dart';
import 'screens/ai_recommendation_screen.dart';

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
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    MarketScreen(),
    PortfolioScreen(),
    NewsScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = [
    "홈",
    "시장",
    "포트폴리오",
    "뉴스",
    "설정",
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.show_chart,
    Icons.account_balance_wallet,
    Icons.article,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: List.generate(
          _titles.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          ),
        ),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIRecommendationScreen(),
                  ),
                );
              },
              child: const Icon(Icons.auto_awesome),
              tooltip: 'AI 추천',
            )
          : null,
    );
  }
}
