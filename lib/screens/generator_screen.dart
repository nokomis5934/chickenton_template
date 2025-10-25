import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:template/controllers/password_controller.dart';

class GeneratorScreen extends StatefulWidget {
  final VoidCallback onPasswordSaved;
  const GeneratorScreen({super.key, required this.onPasswordSaved});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final PasswordController _controller = PasswordController();
  final TextEditingController _siteNameController = TextEditingController();
  String _generatedPassword = '';
  double _length = 12;
  bool _useUppercase = true;
  bool _useNumbers = true;
  bool _useSpecial = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = _controller.generatePassword(
        length: _length.toInt(),
        useUppercase: _useUppercase,
        useNumbers: _useNumbers,
        useSpecial: _useSpecial,
      );
    });
  }

  Future<void> _savePassword() async {
    if (_siteNameController.text.isEmpty || _generatedPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사이트 이름과 비밀번호를 모두 입력(생성)해주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _controller.savePassword(
        _siteNameController.text,
        _generatedPassword,
      );

      // 저장 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\'${_siteNameController.text}\' 비밀번호가 안전하게 저장되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );

      // 목록 화면 갱신을 요청
      widget.onPasswordSaved();

      // 입력 필드 초기화 및 새 비밀번호 생성
      _siteNameController.clear();
      _generatePassword();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('비밀번호 저장 실패: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('비밀번호가 클립보드에 복사되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. 사이트 이름 입력
          TextField(
            controller: _siteNameController,
            decoration: InputDecoration(
              labelText: '저장할 사이트 이름',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.public),
            ),
          ),
          const SizedBox(height: 20),

          // 2. 생성된 비밀번호 표시
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                _generatedPassword,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.blueGrey),
                onPressed: _copyToClipboard,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. 길이 설정 슬라이더
          Row(
            children: [
              const Text('길이: '),
              Expanded(
                child: Slider(
                  value: _length,
                  min: 8,
                  max: 30,
                  divisions: 22,
                  label: _length.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _length = value;
                      _generatePassword();
                    });
                  },
                ),
              ),
              Text(_length.round().toString()),
            ],
          ),

          // 4. 옵션 스위치
          SwitchListTile(
            title: const Text('대문자 포함'),
            value: _useUppercase,
            onChanged: (bool value) {
              setState(() {
                _useUppercase = value;
                _generatePassword();
              });
            },
            secondary: const Icon(Icons.format_size),
          ),
          SwitchListTile(
            title: const Text('숫자 포함'),
            value: _useNumbers,
            onChanged: (bool value) {
              setState(() {
                _useNumbers = value;
                _generatePassword();
              });
            },
            secondary: const Icon(Icons.onetwothree),
          ),
          SwitchListTile(
            title: const Text('특수 문자 포함'),
            value: _useSpecial,
            onChanged: (bool value) {
              setState(() {
                _useSpecial = value;
                _generatePassword();
              });
            },
            secondary: const Icon(Icons.star),
          ),
          const SizedBox(height: 20),

          // 5. 버튼 그룹
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('재생성'),
                  onPressed: _generatePassword,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? '저장 중...' : '저장'),
                  onPressed: _isSaving ? null : _savePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
