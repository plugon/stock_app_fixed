import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/new_screens/news_screen.dart';
import 'screens/new_screens/market_screen.dart';
import 'screens/new_screens/portfolio_screen.dart';
import 'screens/new_screens/settings_screen.dart';
import 'screens/ai_recommendation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '증권 앱',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 시스템 설정에 따라 테마 모드 자동 전환
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const MarketScreen(),
    const PortfolioScreen(),
    const NewsScreen(),
    const SettingsScreen(),
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animationController,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: List.generate(
          _titles.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          ),
        ),
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => 
                      const AIRecommendationScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(0.0, 1.0);
                      var end = Offset.zero;
                      var curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              tooltip: 'AI 추천',
              child: const Icon(Icons.auto_awesome),
            )
          : null,
    );
  }
}
