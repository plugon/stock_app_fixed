import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _useRealTimeData = true;
  bool _showNotifications = true;
  String _selectedApiSource = 'Yahoo Finance';
  String _selectedRefreshInterval = '1분';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "⚙️ 설정",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader("앱 설정"),
          SwitchListTile(
            title: const Text("다크 모드"),
            subtitle: const Text("어두운 테마로 앱을 표시합니다"),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode),
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
            secondary: const Icon(Icons.update),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("알림 표시"),
            subtitle: const Text("주요 주식 변동 및 뉴스 알림을 표시합니다"),
            value: _showNotifications,
            onChanged: (value) {
              setState(() {
                _showNotifications = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          ListTile(
            title: const Text("데이터 소스"),
            subtitle: Text(_selectedApiSource),
            leading: const Icon(Icons.cloud),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showApiSourceDialog();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("데이터 갱신 주기"),
            subtitle: Text(_selectedRefreshInterval),
            leading: const Icon(Icons.timer),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showRefreshIntervalDialog();
            },
          ),
          
          _buildSectionHeader("계정"),
          ListTile(
            title: const Text("프로필 관리"),
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 프로필 관리 화면으로 이동
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("알림 설정"),
            leading: const Icon(Icons.notifications_active),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 알림 설정 화면으로 이동
            },
          ),
          
          _buildSectionHeader("정보"),
          ListTile(
            title: const Text("앱 정보"),
            subtitle: const Text("버전 1.0.0"),
            leading: const Icon(Icons.info),
            onTap: () {
              // 앱 정보 표시
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("도움말"),
            leading: const Icon(Icons.help),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 도움말 화면으로 이동
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("개인정보 처리방침"),
            leading: const Icon(Icons.privacy_tip),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 개인정보 처리방침 화면으로 이동
            },
          ),
          
          _buildSectionHeader("데이터 관리"),
          ListTile(
            title: const Text("캐시 삭제"),
            leading: const Icon(Icons.cleaning_services),
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("데이터 초기화"),
            leading: const Icon(Icons.restore),
            onTap: () {
              _showResetDataDialog();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  void _showApiSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("데이터 소스 선택"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioListTile("Yahoo Finance", _selectedApiSource),
              _buildRadioListTile("공공데이터포털", _selectedApiSource),
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
          }
        });
        Navigator.of(context).pop();
      },
    );
  }

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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("캐시가 삭제되었습니다.")),
                );
                Navigator.of(context).pop();
              },
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
  }

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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("모든 데이터가 초기화되었습니다.")),
                );
                Navigator.of(context).pop();
              },
              child: const Text("초기화"),
            ),
          ],
        );
      },
    );
  }
}
