// lib/screens/setup_pin_screen.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/services.dart';

class SetupPinScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final VoidCallback onPinSet;

  SetupPinScreen({super.key, required this.onPinSet});

  Future<void> _handleSetup(BuildContext context) async {
    final pin = _pinController.text;
    final confirm = _confirmController.text;

    if (pin.isEmpty || confirm.isEmpty) {
      _showSnackbar(context, 'PIN을 입력해주세요.');
      return;
    }
    if (pin.length < 4) {
      _showSnackbar(context, 'PIN은 4자 이상이어야 합니다.');
      return;
    }
    if (pin != confirm) {
      _showSnackbar(context, 'PIN이 일치하지 않습니다.');
      return;
    }

    await _authController.setMasterKey(pin);
    _showSnackbar(context, '마스터 PIN이 설정되었습니다. 앱을 재시작합니다.');

    // 성공적으로 설정 후 앱 재시작을 유도
    onPinSet();
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마스터 PIN 설정')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '최초 실행입니다. 마스터 PIN을 설정해주세요.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // PIN 입력 필드
              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '새 PIN 입력 (4자리 이상)',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),
              // PIN 확인 필드
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'PIN 확인'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _handleSetup(context),
                child: const Text('PIN 설정 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
