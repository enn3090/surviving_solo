import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualInputPage extends StatefulWidget {
  const ManualInputPage({super.key});

  @override
  State<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  // --- 날짜 선택 달력을 보여주는 함수 ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // [ ★★★ 수정 ★★★ ]
  // --- Firebase에 저장하는 함수 (진짜) ---
  Future<void> _saveItem() async {
    if (_isLoading) return;
    if (!mounted) return;

    // 1. 유효성 검사
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품명을 입력해주세요.')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유통기한을 선택해주세요.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 2. 현재 로그인한 사용자 정보 가져오기
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // (보안 규칙 때문에 로그인이 꼭 필요합니다)
        throw Exception("로그인한 사용자를 찾을 수 없습니다.");
      }
      final String uid = user.uid;

      // 3. Firebase Firestore에 데이터 저장
      await FirebaseFirestore.instance
          .collection('refrigerator') // 'refrigerator' 컬렉션에
          .add({
        'uid': uid, // ⬅️ 누가 저장했는지 (내 아이템 식별용)
        'name': _nameController.text.trim(), // ⬅️ 상품명
        'expiresAt': _selectedDate, // ⬅️ 유통기한
        'createdAt': FieldValue.serverTimestamp(), // ⬅️ 등록일
      });

      // 4. 저장 성공
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('냉장고에 저장되었습니다!')),
      );
      Navigator.of(context).pop(); // 저장 후 이전 화면으로 돌아가기

    } catch (e) {
      // 5. 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장에 실패했습니다: $e')),
        );
      }
    }

    // 6. 로딩 종료
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('직접 입력'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _saveItem, // [ ★★★ 확인 ★★★ ] 진짜 저장 함수 연결
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blueAccent,
                ),
              )
                  : const Text(
                '저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. 상품명 입력 ---
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '상품명',
                hintText: '예: 우유 1L',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. 유통기한 입력 (날짜 선택기) ---
            TextField(
              onTap: () => _selectDate(context),
              readOnly: true,
              decoration: InputDecoration(
                labelText: '유통기한',
                hintText: _selectedDate == null
                    ? '날짜를 선택하세요'
                    : DateFormat('yyyy년 MM월 dd일').format(_selectedDate!),
                hintStyle: _selectedDate != null
                    ? const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)
                    : null,
                suffixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}