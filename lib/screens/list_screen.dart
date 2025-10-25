// lib/screens/list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/password_controller.dart';
import '../models/password_entry.dart';
// Note: 이 파일에 PasswordController, PasswordEntry, EncryptionHelper 클래스가
// import되어 있거나 정의되어 있어야 합니다.

// =======================================================
// 1. GlobalKey 접근을 위한 공개 타입 정의 (핵심 수정)
// =======================================================
// main.dart의 GlobalKey<ListScreenState>가 _ListScreenState에 접근할 수 있도록
// ListScreenState 타입을 공개적으로 정의합니다.
typedef ListScreenState = _ListScreenState;

class ListScreen extends StatefulWidget {
  final VoidCallback onDeleted;
  const ListScreen({super.key, required this.onDeleted});

  @override
  // createState()가 공개 타입인 ListScreenState를 반환하도록 합니다.
  State<ListScreen> createState() => ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final PasswordController _controller = PasswordController();
  List<PasswordEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 2. 초기화 시 데이터 로드
    loadEntries();
  }

  // =======================================================
  // 3. 외부 호출을 위한 공개 메서드 (핵심 메서드)
  // =======================================================
  // main.dart의 _onPasswordAction()에서 GlobalKey를 통해 이 함수를 호출합니다.
  Future<void> loadEntries() async {
    // 로딩 시작
    setState(() => _isLoading = true);

    // 데이터 로드
    final entries = await _controller.loadPasswords();

    // 로딩 완료 및 상태 갱신
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _handleDelete(int id) async {
    await _controller.deletePassword(id);
    loadEntries(); // 삭제 후 목록 갱신
    widget.onDeleted(); // HomeScreen에 데이터 변경을 알림 (선택 사항)
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entries.isEmpty) {
      return const Center(child: Text('저장된 비밀번호가 없습니다.'));
    }

    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Slidable(
          key: ValueKey(entry.id), // 슬라이드 오류 방지를 위해 Key 추가 (선택 사항)
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (ctx) => _handleDelete(entry.id!), // 삭제 함수 호출
                backgroundColor: Colors.red,
                icon: Icons.delete,
                label: '삭제',
              ),
            ],
          ),
          child: PasswordListItem(entry: entry, controller: _controller),
        );
      },
    );
  }
}

// =======================================================
// 4. 비밀번호 목록 항목 위젯 (PasswordListItem)
// =======================================================
class PasswordListItem extends StatefulWidget {
  final PasswordEntry entry;
  final PasswordController controller;
  const PasswordListItem({
    super.key,
    required this.entry,
    required this.controller,
  });

  @override
  State<PasswordListItem> createState() => _PasswordListItemState();
}

class _PasswordListItemState extends State<PasswordListItem> {
  bool _isObscured = true;

  void _copyPassword(BuildContext context) {
    final decryptedPassword = widget.controller.decryptPassword(
      widget.entry.encryptedPassword,
    );
    Clipboard.setData(ClipboardData(text: decryptedPassword));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('클립보드에 복사되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    final decryptedPassword = widget.controller.decryptPassword(
      widget.entry.encryptedPassword,
    );

    return ListTile(
      title: Text(
        widget.entry.siteName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(_isObscured ? '••••••••••••' : decryptedPassword),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _isObscured = !_isObscured);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyPassword(context),
          ),
        ],
      ),
      onTap: () {
        setState(() => _isObscured = !_isObscured);
      },
    );
  }
}
