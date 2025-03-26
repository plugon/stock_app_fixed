import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/stock_model.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  bool _isDarkMode = false;
  bool _useRealTimeData = true;
  bool _showNotifications = true;
  String _selectedApiSource = '공공데이터포털';
  String _selectedRefreshInterval = '1분';
  String _apiKey = ''; // API 키 저장 변수
  
  // 검색 관련 설정
  bool _enableAutoComplete = true;
  bool _prioritizeWatchlist = true;
  
  // 알림 관련 설정
  bool _priceAlerts = true;
  bool _newsAlerts = true;
  bool _earningsAlerts = false;
  
  // 차트 관련 설정
  String _defaultChartPeriod = '1개월';
  String _defaultChartType = '캔들스틱';
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "설정",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '설정 검색',
            onPressed: () {
              _showSettingsSearch();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // 앱 설정 섹션
          _buildSectionHeader(context, "앱 설정"),
          _buildSettingCard(
            context,
            children: [
              SwitchListTile(
                title: const Text("다크 모드"),
                subtitle: const Text("어두운 테마로 앱을 표시합니다"),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  // 실제 구현에서는 여기서 앱 테마 변경
                },
                secondary: Icon(
                  Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text("실시간 데이터 사용"),
                subtitle: const Text("실시간 주식 데이터를 가져옵니다 (데이터 사용량 증가)"),
                value: _useRealTimeData,
                onChanged: (value) {
                  setState(() {
                    _useRealTimeData = value;
                  });
                },
                secondary: Icon(
                  Icons.update,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text("데이터 소스"),
                subtitle: Text(_selectedApiSource),
                leading: Icon(
                  Icons.cloud,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showApiSourceDialog();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("데이터 갱신 주기"),
                subtitle: Text(_selectedRefreshInterval),
                leading: Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showRefreshIntervalDialog();
                },
              ),
            ],
          ),
          
          // API 키 관리 섹션
          _buildSectionHeader(context, "API 키 관리"),
          _buildSettingCard(
            context,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "공공데이터포털 API 키",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "데이터를 가져오기 위한 API 키를 입력하세요.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "API 키 입력",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.content_paste),
                          tooltip: '클립보드에서 붙여넣기',
                          onPressed: () async {
                            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                            if (clipboardData?.text != null) {
                              setState(() {
                                _apiKey = clipboardData!.text!;
                              });
                            }
                          },
                        ),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _apiKey = value;
                        });
                      },
                      controller: TextEditingController(text: _apiKey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.help_outline),
                          label: const Text("API 키 얻는 방법"),
                          onPressed: () {
                            _showApiKeyHelpDialog();
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // API 키 검증 로직
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("API 키가 저장되었습니다.")),
                            );
                          },
                          child: const Text("저장"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 검색 설정 섹션
          _buildSectionHeader(context, "검색 설정"),
          _buildSettingCard(
            context,
            children: [
              SwitchListTile(
                title: const Text("자동완성 기능"),
                subtitle: const Text("검색 시 자동완성 제안을 표시합니다"),
                value: _enableAutoComplete,
                onChanged: (value) {
                  setState(() {
                    _enableAutoComplete = value;
                  });
                },
                secondary: Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text("관심종목 우선 표시"),
                subtitle: const Text("검색 결과에서 관심종목을 우선적으로 표시합니다"),
                value: _prioritizeWatchlist,
                onChanged: (value) {
                  setState(() {
                    _prioritizeWatchlist = value;
                  });
                },
                secondary: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          // 알림 설정 섹션
          _buildSectionHeader(context, "알림 설정"),
          _buildSettingCard(
            context,
            children: [
              SwitchListTile(
                title: const Text("알림 표시"),
                subtitle: const Text("주요 주식 변동 및 뉴스 알림을 표시합니다"),
                value: _showNotifications,
                onChanged: (value) {
                  setState(() {
                    _showNotifications = value;
                  });
                },
                secondary: Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (_showNotifications) ...[
                const Divider(),
                SwitchListTile(
                  title: const Text("가격 알림"),
                  subtitle: const Text("설정한 가격에 도달하면 알림을 표시합니다"),
                  value: _priceAlerts,
                  onChanged: (value) {
                    setState(() {
                      _priceAlerts = value;
                    });
                  },
                  secondary: Icon(
                    Icons.price_change,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("뉴스 알림"),
                  subtitle: const Text("관심종목 관련 주요 뉴스가 있을 때 알림을 표시합니다"),
                  value: _newsAlerts,
                  onChanged: (value) {
                    setState(() {
                      _newsAlerts = value;
                    });
                  },
                  secondary: Icon(
                    Icons.newspaper,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("실적 발표 알림"),
                  subtitle: const Text("관심종목의 실적 발표 일정을 알려줍니다"),
                  value: _earningsAlerts,
                  onChanged: (value) {
                    setState(() {
                      _earningsAlerts = value;
                    });
                  },
                  secondary: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          
          // 차트 설정 섹션
          _buildSectionHeader(context, "차트 설정"),
          _buildSettingCard(
            context,
            children: [
              ListTile(
                title: const Text("기본 차트 기간"),
                subtitle: Text(_defaultChartPeriod),
                leading: Icon(
                  Icons.date_range,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showChartPeriodDialog();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("기본 차트 유형"),
                subtitle: Text(_defaultChartType),
                leading: Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showChartTypeDialog();
                },
              ),
            ],
          ),
          
          // QR 코드 스캔 섹션
          _buildSectionHeader(context, "QR 코드 스캔"),
          _buildSettingCard(
            context,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "QR 코드로 종목 추가",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "QR 코드를 스캔하여 종목 정보를 빠르게 추가할 수 있습니다.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("QR 코드 스캔하기"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          _showQrCodeScanner();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      "내 포트폴리오 QR 코드",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "이 QR 코드를 공유하여 다른 사용자가 당신의 포트폴리오를 볼 수 있습니다.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: QrImageView(
                        data: 'https://stockapp.example.com/portfolio/user123',
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("QR 코드 공유하기"),
                        onPressed: () {
                          // QR 코드 공유 로직
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 데이터 관리 섹션
          _buildSectionHeader(context, "데이터 관리"),
          _buildSettingCard(
            context,
            children: [
              ListTile(
                title: const Text("캐시 삭제"),
                subtitle: const Text("임시 데이터를 삭제하여 저장 공간을 확보합니다"),
                leading: Icon(
                  Icons.cleaning_services,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  _showClearCacheDialog();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("데이터 내보내기"),
                subtitle: const Text("포트폴리오 및 설정 데이터를 내보냅니다"),
                leading: Icon(
                  Icons.upload_file,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  _showExportDataDialog();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("데이터 가져오기"),
                subtitle: const Text("이전에 내보낸 데이터를 가져옵니다"),
                leading: Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  _showImportDataDialog();
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  "데이터 초기화",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: const Text("모든 앱 데이터를 초기화합니다"),
                leading: Icon(
                  Icons.restore,
                  color: Theme.of(context).colorScheme.error,
                ),
                onTap: () {
                  _showResetDataDialog();
                },
              ),
            ],
          ),
          
          // 정보 섹션
          _buildSectionHeader(context, "정보"),
          _buildSettingCard(
            context,
            children: [
              ListTile(
                title: const Text("앱 정보"),
                subtitle: const Text("버전 1.0.0"),
                leading: Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  _showAppInfoDialog();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("도움말"),
                subtitle: const Text("앱 사용 방법 및 FAQ"),
                leading: Icon(
                  Icons.help,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 도움말 화면으로 이동
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("개인정보 처리방침"),
                leading: Icon(
                  Icons.privacy_tip,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 개인정보 처리방침 화면으로 이동
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("오픈소스 라이선스"),
                leading: Icon(
                  Icons.code,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 오픈소스 라이선스 화면으로 이동
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 섹션 헤더 위젯
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // 설정 카드 위젯
  Widget _buildSettingCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // 설정 검색 다이얼로그
  void _showSettingsSearch() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("설정 검색"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "검색어 입력",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text(
                "검색 결과가 여기에 표시됩니다.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  // API 소스 선택 다이얼로그
  void _showApiSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("데이터 소스 선택"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioListTile("공공데이터포털", _selectedApiSource),
              _buildRadioListTile("Yahoo Finance", _selectedApiSource),
              _buildRadioListTile("한국투자증권 API", _selectedApiSource),
              _buildRadioListTile("IEX Cloud", _selectedApiSource),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // 데이터 갱신 주기 선택 다이얼로그
  void _showRefreshIntervalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("데이터 갱신 주기 선택"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioListTile("실시간", _selectedRefreshInterval),
              _buildRadioListTile("1분", _selectedRefreshInterval),
              _buildRadioListTile("5분", _selectedRefreshInterval),
              _buildRadioListTile("15분", _selectedRefreshInterval),
              _buildRadioListTile("30분", _selectedRefreshInterval),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // 차트 기간 선택 다이얼로그
  void _showChartPeriodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("기본 차트 기간 선택"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioListTile("1일", _defaultChartPeriod),
              _buildRadioListTile("1주일", _defaultChartPeriod),
              _buildRadioListTile("1개월", _defaultChartPeriod),
              _buildRadioListTile("3개월", _defaultChartPeriod),
              _buildRadioListTile("6개월", _defaultChartPeriod),
              _buildRadioListTile("1년", _defaultChartPeriod),
              _buildRadioListTile("5년", _defaultChartPeriod),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // 차트 유형 선택 다이얼로그
  void _showChartTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("기본 차트 유형 선택"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioListTile("캔들스틱", _defaultChartType),
              _buildRadioListTile("라인", _defaultChartType),
              _buildRadioListTile("OHLC", _defaultChartType),
              _buildRadioListTile("영역", _defaultChartType),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // API 키 도움말 다이얼로그
  void _showApiKeyHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("API 키 얻는 방법"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "공공데이터포털 API 키 발급 방법",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("1. 공공데이터포털(data.go.kr)에 회원가입 및 로그인"),
                const Text("2. 원하는 API 검색 (예: '주식시세정보')"),
                const Text("3. 활용신청 버튼 클릭 및 신청 양식 작성"),
                const Text("4. 승인 후 마이페이지 > 개발계정에서 API 키 확인"),
                const SizedBox(height: 16),
                Text(
                  "API 키 사용 시 주의사항",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("• API 키는 개인 정보이므로 타인과 공유하지 마세요."),
                const Text("• 일일 API 호출 한도가 있으므로 과도한 요청을 피하세요."),
                const Text("• 상업적 용도로 사용 시 별도의 이용 약관을 확인하세요."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // QR 코드 스캐너 다이얼로그
  void _showQrCodeScanner() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR 코드 스캔"),
          content: SizedBox(
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "실제 구현에서는 여기에 카메라 미리보기가 표시됩니다.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 스캔 성공 시 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("QR 코드 스캔 완료: 삼성전자 종목이 추가되었습니다.")),
                    );
                  },
                  child: const Text("테스트: 스캔 성공"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
          ],
        );
      },
    );
  }

  // 캐시 삭제 확인 다이얼로그
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("캐시 삭제"),
          content: const Text("앱의 캐시 데이터를 삭제하시겠습니까? 이 작업은 앱 성능을 향상시킬 수 있지만, 일부 데이터를 다시 다운로드해야 할 수 있습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                // 캐시 삭제 로직
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("캐시가 삭제되었습니다.")),
                );
              },
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  // 데이터 내보내기 다이얼로그
  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("데이터 내보내기"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("다음 데이터를 내보냅니다:"),
              const SizedBox(height: 8),
              _buildCheckboxListTile("포트폴리오 데이터", true),
              _buildCheckboxListTile("관심종목 목록", true),
              _buildCheckboxListTile("앱 설정", true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("데이터가 내보내기 되었습니다.")),
                );
              },
              child: const Text("내보내기"),
            ),
          ],
        );
      },
    );
  }

  // 데이터 가져오기 다이얼로그
  void _showImportDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("데이터 가져오기"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("이전에 내보낸 데이터 파일을 선택하세요."),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.file_open),
                label: const Text("파일 선택"),
                onPressed: () {
                  // 파일 선택 로직
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("데이터를 성공적으로 가져왔습니다.")),
                );
              },
              child: const Text("가져오기"),
            ),
          ],
        );
      },
    );
  }

  // 데이터 초기화 확인 다이얼로그
  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("데이터 초기화"),
          content: const Text("모든 앱 데이터를 초기화하시겠습니까? 이 작업은 되돌릴 수 없으며, 모든 사용자 데이터가 삭제됩니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                // 데이터 초기화 로직
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("모든 데이터가 초기화되었습니다.")),
                );
              },
              child: const Text("초기화"),
            ),
          ],
        );
      },
    );
  }

  // 앱 정보 다이얼로그
  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("앱 정보"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bar_chart,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                "주식 앱",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text("버전 1.0.0"),
              const SizedBox(height: 16),
              const Text(
                "© 2025 주식 앱 개발팀",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "이 앱은 실시간 주식 정보 제공 및 포트폴리오 관리를 위한 앱입니다.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // 라디오 리스트 타일 위젯
  Widget _buildRadioListTile(String title, String groupValue) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: groupValue,
      onChanged: (value) {
        setState(() {
          if (groupValue == _selectedApiSource) {
            _selectedApiSource = value!;
          } else if (groupValue == _selectedRefreshInterval) {
            _selectedRefreshInterval = value!;
          } else if (groupValue == _defaultChartPeriod) {
            _defaultChartPeriod = value!;
          } else if (groupValue == _defaultChartType) {
            _defaultChartType = value!;
          }
        });
        Navigator.of(context).pop();
      },
    );
  }

  // 체크박스 리스트 타일 위젯
  Widget _buildCheckboxListTile(String title, bool value) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) {
        // 실제 구현에서는 여기서 상태 변경
      },
    );
  }
}
