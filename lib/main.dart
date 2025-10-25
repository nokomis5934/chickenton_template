// lib/main.dart
import 'package:flutter/material.dart';
import 'package:template/controllers/auth_controller.dart';
import 'package:template/controllers/database_controller.dart';
import 'package:template/screens/auth_screen.dart';
import 'package:template/screens/generator_screen.dart';
import 'package:template/screens/list_screen.dart';
import 'package:template/screens/setup_pin_screen.dart';

// -------------------------------------------------------------------
// 1. 앱 진입점 및 초기화 (main)
// -------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 앱 실행 전에 DB 초기화 보장
  await DatabaseController.instance.database;
  runApp(const PasswordVaultApp());
}

class PasswordVaultApp extends StatelessWidget {
  const PasswordVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로컬 비밀번호 금고',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const AppEntry(), // 앱 시작점: 인증 분기 처리
    );
  }
}

// -------------------------------------------------------------------
// 2. 앱 진입점 (AppEntry): 인증 분기 처리
// -------------------------------------------------------------------

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  final AuthController _authController = AuthController();
  bool _isLoading = true;
  bool _isMasterKeySet = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isSet = await _authController.isMasterKeySet();
    setState(() {
      _isMasterKeySet = isSet;
      _isLoading = false;
    });
  }

  // PIN 설정 또는 인증 성공 시 호출되는 콜백
  void _onSuccess() {
    // Navigator를 사용하여 현재 화면을 제거하고 HomeScreen으로 교체 (인증 성공 시)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isMasterKeySet) {
      // 1. 마스터 PIN이 설정되지 않은 경우 -> 설정 화면
      return SetupPinScreen(onPinSet: _onSuccess);
    } else {
      // 2. 마스터 PIN이 설정된 경우 -> 인증 화면
      return AuthScreen(onAuthenticated: _onSuccess);
    }
  }
}

// -------------------------------------------------------------------
// 3. 메인 콘텐츠 화면 (HomeScreen): 인증 후 진입
// -------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // GlobalKey의 타입으로 ListScreenState를 사용합니다.
  // 이 타입은 lib/screens/list_screen.dart에서 정의해야 정상 작동합니다.
  final GlobalKey<ListScreenState> _listKey = GlobalKey();

  // 목록 갱신을 위한 콜백
  void _onPasswordAction() {
    // GlobalKey를 통해 ListScreenState의 loadEntries() 공개 메서드를 호출합니다.
    _listKey.currentState?.loadEntries();
  }

  // 화면 목록 정의
  late final List<Widget> _widgetOptions = <Widget>[
    GeneratorScreen(onPasswordSaved: _onPasswordAction),
    // GlobalKey를 ListScreen에 전달
    ListScreen(key: _listKey, onDeleted: _onPasswordAction),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 목록 탭을 누를 때 데이터 갱신을 요청 (최신 데이터 보장)
    if (index == 1) {
      _onPasswordAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로컬 비밀번호 금고')),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: '생성'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '목록'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
