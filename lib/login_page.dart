import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Firebase Auth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 이메일, 비밀번호 입력을 위한 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 로딩 중 상태 (버튼 중복 클릭 방지)
  bool _isLoading = false;

  // 오류 메시지
  String _errorMessage = '';
  // 회원가입 성공 메시지 (추가)
  String _successMessage = '';

  // --- 1. 로그인 함수 ---
  Future<void> _signIn() async {
    // 이미 로딩 중이면 함수 종료
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // 오류 메시지 초기화
      _successMessage = ''; // 성공 메시지도 초기화 (수정)
    });

    try {
      // Firebase Auth로 이메일/비밀번호 로그인 시도
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // 로그인이 성공하면, AuthWrapper가 자동으로 홈 화면으로 보냅니다.
    } on FirebaseAuthException catch (e) {
      // 로그인 실패 시 오류 메시지 설정
      if (e.code == 'user-not-found') {
        _errorMessage = '등록된 이메일이 없습니다.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = '비밀번호가 틀렸습니다.';
      } else {
        _errorMessage = '로그인에 실패했습니다: ${e.message}';
      }
    } catch (e) {
      _errorMessage = '알 수 없는 오류가 발생했습니다.';
    }

    // 함수 종료 후 로딩 상태 해제
    // (로그인 실패 시에만 setState가 호출되도록 수정)
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- 2. 회원가입 함수 ---
  Future<void> _register() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = ''; // 메시지 초기화 (수정)
    });

    try {
      // Firebase Auth로 새 계정 생성
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ★★★ [수정] 회원가입 성공 시, 자동 로그인을 막기 위해 즉시 로그아웃 ★★★
      await _auth.signOut();

      // 성공 메시지 설정 (수정)
      setState(() {
        _successMessage = '회원가입 성공! 이제 로그인해주세요.';
        _emailController.clear(); // 입력 필드 초기화
        _passwordController.clear(); // 입력 필드 초기화
      });
      // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = '비밀번호가 너무 짧습니다. (6자 이상)';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = '이미 사용 중인 이메일입니다.';
      } else {
        _errorMessage = '회원가입에 실패했습니다: ${e.message}';
      }
    } catch (e) {
      _errorMessage = '알 수 없는 오류가 발생했습니다.';
    }

    // 함수 종료 후 로딩 상태 해제 (수정)
    setState(() {
      _isLoading = false;
    });
  }

  // --- 3. UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('자취생존 로그인'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            const Text(
              '환영합니다!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '로그인 또는 회원가입을 해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // --- 이메일 입력 ---
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // --- 비밀번호 입력 ---
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호 (6자 이상)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true, // 비밀번호 가리기
            ),
            const SizedBox(height: 24),

            // --- 오류 메시지 표시 ---
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            // --- [수정] 성공 메시지 표시 (추가) ---
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _successMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),

            // --- 로그인 버튼 ---
            ElevatedButton(
              // _isLoading이 true이면 null (비활성화), false이면 _signIn 함수 연결
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                // 로딩 중일 때
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                // 평소
                '로그인',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),

            // --- 회원가입 버튼 ---
            TextButton(
              onPressed: _isLoading ? null : _register,
              child: const Text(
                '이메일로 회원가입',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}