// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  final TextEditingController _pinController = TextEditingController();
  final VoidCallback onAuthenticated;

  AuthScreen({super.key, required this.onAuthenticated});

  Future<void> _handleAuth(BuildContext context) async {
    final pin = _pinController.text;

    if (pin.isEmpty) {
      _showSnackbar(context, 'PIN을 입력해주세요.');
      return;
    }

    final success = await _authController.authenticate(pin);

    if (success) {
      onAuthenticated(); // 인증 성공 시 메인 화면으로 이동
    } else {
      _pinController.clear();
      _showSnackbar(context, 'PIN이 일치하지 않습니다.');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보안 인증')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '앱에 접근하려면 마스터 PIN을 입력하세요.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // PIN 입력 필드
              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '마스터 PIN'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) => _handleAuth(context),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _handleAuth(context),
                child: const Text('잠금 해제'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
