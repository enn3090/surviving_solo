import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'refrigerator_page.dart';
import 'supplies_page.dart';
import 'scan_page.dart';
import 'community_page.dart';
import 'manual_input_page.dart';
import 'recycling_setup_page.dart';

// -----------------------------------------------
// main 함수: 앱의 시작점 (Firebase 초기화)
// -----------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// -----------------------------------------------
// 1. 앱의 루트 위젯 (MaterialApp)
// -----------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '자취생존',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        canvasColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// -----------------------------------------------
// 2. 로그인 상태를 감시하는 '관제탑' 위젯
// -----------------------------------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

// -----------------------------------------------
// 3. 하단 탭 네비게이션을 관리하는 메인 화면
// -----------------------------------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _widgetOptions = <Widget>[
    const CommunityPage(), // 0번 탭
    Navigator( // 1번 탭 (홈)
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder = (BuildContext context) => const HomeScreenBody();
            break;
          default:
            builder = (BuildContext context) =>
            const Center(child: Text('Unknown route'));
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    ),
    const MyPageBody(), // 2번 탭
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// -----------------------------------------------
// 4. 실제 '홈' 탭에 들어갈 내용
// -----------------------------------------------
class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () {},
                  ),
                  const Text(
                    '자취생존',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNotificationBanner(),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Text(
                    '영현님, 오늘도 똑똑한 자취생활 하세요!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTag('홈', isSelected: true),
                    const SizedBox(width: 8),
                    _buildTag('오늘의 요리'),
                    const SizedBox(width: 8),
                    _buildTag('#자취일상'),
                    const SizedBox(width: 8),
                    _buildTag('#냉장고털이'),
                    const SizedBox(width: 8),
                    _buildTag('#분리수거'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                '• 유통기한 임박 5개',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              // [ ★★★ 수정됨: const 제거 ★★★ ]
              _buildLargeButton(
                context,
                '나의 냉장고',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RefrigeratorPage(), // const 제거됨
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // [ ★★★ 수정됨: const 제거 ★★★ ]
              _buildLargeButton(
                context,
                '나의 생필품',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuppliesPage(), // const 제거됨
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              _buildScanBanner(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLargeButton(
      BuildContext context,
      String title,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((255 * 0.1).round()),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[100]?.withAlpha((255 * 0.6).round()),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[100]?.withAlpha((255 * 0.6).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.blueAccent, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '영수증을 스캔해보세요.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '영수증 스캔을 통하여 쉽게 상품을 등록할 수 있으며, 유통기한이 임박한 상품을 알려드립니다.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA).withAlpha((255 * 0.7).round()),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Row(
        children: [
          Icon(Icons.recycling_rounded, color: Color(0xFF0097A7)),
          SizedBox(width: 10),
          Text(
            '오늘은 플라스틱, 비닐을 버리는 날입니다!',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF00838F),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------
// 5. '마이' 탭에 들어갈 내용
// -----------------------------------------------
class MyPageBody extends StatelessWidget {
  const MyPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? '로그인 정보 없음';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Icons.account_circle,
                    size: 60, color: Colors.blueAccent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        '오늘도 행복한 하루 되세요!:)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(thickness: 8, color: Color(0xFFF0F0F0)),
          _buildSectionTitle('앱 설정'),
          _buildListTile(
            context,
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            onTap: () {},
          ),

          _buildListTile(
            context,
            icon: Icons.recycling_outlined,
            title: '분리수거 요일 설정',
            onTap: () {
              // 버튼 누르면 페이지 이동!
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecyclingSetupPage()),
              );
            },
          ),

          const Divider(thickness: 8, color: Color(0xFFF0F0F0)),
          _buildSectionTitle('기타'),
          _buildListTile(
            context,
            icon: Icons.campaign_outlined,
            title: '공지사항',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.support_agent_outlined,
            title: '고객센터',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.description_outlined,
            title: '이용약관',
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text('로그아웃', style: TextStyle(color: Colors.grey)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      child: const Text('취소'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('로그아웃',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('회원 탈퇴', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing:
      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}