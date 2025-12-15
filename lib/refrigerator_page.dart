import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// -----------------------------------------------
// [ 1. 데이터 모델: 요리 정보 ]
// -----------------------------------------------
class Recipe {
  final String name;
  final List<String> requiredIngredients;
  final String description;
  final List<String> cookingSteps;

  Recipe(this.name, this.requiredIngredients, this.description, this.cookingSteps);
}

class RefrigeratorPage extends StatefulWidget {
  const RefrigeratorPage({super.key});

  @override
  State<RefrigeratorPage> createState() => _RefrigeratorPageState();
}

class _RefrigeratorPageState extends State<RefrigeratorPage> {
  final Set<String> _selectedItemIds = {};
  final Set<String> _selectedItemNames = {};
  final TextEditingController _searchController = TextEditingController();

  // -----------------------------------------------
  // [ 2. 레시피 데이터베이스 ]
  // -----------------------------------------------
  final List<Recipe> _allRecipes = [
    // --- 밥류 ---
    Recipe('김치볶음밥', ['김치', '계란', '대파', '스팸'], '자취생의 영원한 친구', [
      '대파를 송송 썰어 식용유에 볶아 파기름을 냅니다.',
      '썰어둔 김치와 스팸을 넣고 설탕 0.5큰술과 함께 볶습니다.',
      '김치가 익으면 밥을 넣고 고춧가루 1큰술, 간장 1큰술을 넣어 볶습니다.',
      '참기름을 두르고 계란 후라이를 올려 마무리합니다.'
    ]),
    Recipe('참치마요덮밥', ['참치', '계란', '양파', '마요네즈'], '입맛 없을 때 뚝딱', [
      '양파를 채 썰어 간장, 설탕, 물을 넣고 졸입니다.',
      '계란은 스크램블 에그로 만듭니다.',
      '밥 위에 양파 소스, 스크램블 에그, 기름 뺀 참치를 올립니다.',
      '마요네즈를 예쁘게 뿌리고 김가루가 있다면 추가합니다.'
    ]),
    // ... (기존 레시피 리스트 그대로 유지) ...
    Recipe('스팸마요덮밥', ['스팸', '계란', '양파', '마요네즈'], '단짠단짠 메뉴', [
      '스팸을 깍둑썰기 하여 노릇하게 굽습니다.',
      '양파는 간장 소스(간장2, 설탕1, 물3)에 졸여줍니다.',
      '밥 위에 졸인 양파와 스크램블 에그, 구운 스팸을 올립니다.',
      '마요네즈를 뿌려 비벼 먹습니다.'
    ]),
    Recipe('간장계밥', ['계란', '간장', '참기름', '깨'], '귀찮을 때 1분 컷, 국룰 메뉴', [
      '따뜻한 밥 한 공기를 큰 그릇에 담습니다.',
      '계란 후라이를 반숙으로 조리합니다. (버터가 있다면 밥에 녹여주세요!)',
      '밥 위에 계란을 올리고 간장 1~2큰술, 참기름 1큰술을 뿌립니다.',
      '통깨를 솔솔 뿌려 맛있게 비벼 먹습니다.'
    ]),
    Recipe('오므라이스', ['계란', '양파', '당근', '케찹'], '추억의 맛', [
      '야채(양파, 당근)를 잘게 다져 밥과 함께 볶습니다. (케찹 1큰술 추가)',
      '계란 2개를 풀어 얇게 지단을 만듭니다.',
      '볶음밥을 지단 위에 올리고 잘 감싸줍니다.',
      '케찹이나 돈까스 소스를 뿌려 완성합니다.'
    ]),
    Recipe('제육덮밥', ['삼겹살', '양파', '대파', '고추장'], '든든한 고기 반찬', [
      '고기와 야채를 먹기 좋은 크기로 썹니다.',
      '양념장(고추장2, 간장2, 설탕1, 고춧가루1, 다진마늘1)을 만듭니다.',
      '팬에 고기를 먼저 볶다가 야채와 양념장을 넣고 볶습니다.',
      '밥 위에 듬뿍 얹어 냅니다.'
    ]),
    // --- 국/찌개류 ---
    Recipe('참치김치찌개', ['김치', '참치', '대파', '양파'], '감칠맛 폭발', [
      '냄비에 김치와 참치 기름을 넣고 볶습니다.',
      '물이나 쌀뜨물을 붓고 끓입니다.',
      '양파와 대파, 고춧가루, 다진마늘을 넣습니다.',
      '참치 살을 넣고 간장이나 액젓으로 간을 맞춥니다.'
    ]),
    Recipe('돼지김치찌개', ['김치', '삼겹살', '대파', '두부'], '밥도둑', [
      '냄비에 고기를 넣고 볶다가 김치를 넣어 같이 볶습니다.',
      '물을 붓고 푹 끓입니다. (오래 끓일수록 맛있어요)',
      '두부와 대파, 다진마늘을 넣습니다.',
      '부족한 간은 새우젓이나 국간장으로 합니다.'
    ]),
    Recipe('된장찌개', ['두부', '양파', '대파', '호박'], '고깃집 스타일', [
      '뚝배기에 물을 붓고 된장을 2큰술 풉니다.',
      '야채(양파, 호박)를 넣고 끓입니다.',
      '두부와 대파, 고춧가루 약간을 넣습니다.',
      '쌈장이 있다면 반 스푼 넣어주면 고깃집 맛이 납니다.'
    ]),
    Recipe('순두부찌개', ['순두부', '계란', '대파', '고춧가루'], '얼큰한 맛', [
      '파기름을 내다가 고춧가루를 넣어 고추기름을 만듭니다.',
      '물을 붓고 끓으면 순두부를 넣습니다.',
      '간장, 소금으로 간을 하고 계란을 하나 톡 넣습니다.',
      '마지막에 후추와 대파를 뿌립니다.'
    ]),
    Recipe('북엇국', ['북어', '계란', '대파', '무'], '해장에 최고', [
      '참기름에 북어를 달달 볶습니다.',
      '물을 붓고 나박 썬 무를 넣어 끓입니다.',
      '국간장과 소금으로 간을 하고, 계란물을 풉니다.',
      '파를 넣고 마무리합니다.'
    ]),
    Recipe('만두국', ['만두', '계란', '대파', '김'], '뜨끈한 국물', [
      '멸치 육수나 사골 국물을 끓입니다.',
      '만두를 넣고 익을 때까지 끓입니다.',
      '계란을 풀어 넣고 대파를 송송 썹니다.',
      '그릇에 담고 김가루와 후추를 뿌립니다.'
    ]),
    // --- 면류 ---
    Recipe('파송송계란탁라면', ['라면', '대파', '계란'], '정석 라면', [
      '물 550ml를 끓입니다.',
      '물이 끓으면 면과 스프, 건더기를 넣습니다.',
      '면이 반쯤 익었을 때 대파와 계란을 넣습니다.',
      '꼬들한 면을 원하면 면을 들었다 놨다 해주세요.'
    ]),
    Recipe('우유라면', ['우유', '라면', '고춧가루'], '로제 느낌 라면', [
      '면을 먼저 삶아 물을 버립니다.',
      '우유 300ml 정도를 붓고 스프와 고춧가루를 넣습니다.',
      '우유가 끓어오르면 불을 끄고 먹습니다. (고소함 폭발!)'
    ]),
    Recipe('김치비빔국수', ['소면', '김치', '고추장', '참기름'], '새콤달콤', [
      '소면을 삶아 찬물에 빡빡 씻습니다.',
      '김치를 잘게 썰고 고추장, 설탕, 식초, 참기름을 섞습니다.',
      '면과 양념장을 잘 비벼줍니다.',
      '삶은 계란이 있다면 올려주세요.'
    ]),
    Recipe('간장비빔국수', ['소면', '간장', '설탕', '참기름'], '담백한 야식', [
      '소면을 삶아 찬물에 헹굽니다.',
      '간장2, 설탕1, 참기름1 비율로 소스를 만듭니다.',
      '면에 소스를 넣고 비빈 후 깨를 뿌립니다.',
      '쪽파나 김가루를 곁들이면 더 맛있습니다.'
    ]),
    // --- 반찬/안주 ---
    Recipe('계란말이', ['계란', '대파', '당근'], '도시락 반찬 1순위', [
      '계란 3~4개를 풀고 다진 야채(대파, 당근)를 넣습니다.',
      '팬에 기름을 두르고 계란물을 얇게 붓습니다.',
      '끝에서부터 돌돌 말아주며 계란물을 이어 붓습니다.',
      '한 김 식힌 후 썰어야 예쁘게 썰립니다.'
    ]),
    Recipe('두부김치', ['두부', '김치', '참기름', '깨'], '막걸리 안주', [
      '두부는 끓는 물에 살짝 데쳐 따뜻하게 준비합니다.',
      '김치는 참기름과 설탕을 넣고 볶습니다.',
      '접시에 두부와 볶은 김치를 예쁘게 담습니다.',
      '두부 위에 검은 깨를 뿌리면 더 좋습니다.'
    ]),
    Recipe('쏘야볶음', ['소세지', '양파', '피망', '케찹'], '맥주 안주', [
      '소세지에 칼집을 냅니다.',
      '야채를 먹기 좋게 썹니다.',
      '팬에 소세지와 야채를 볶다가 케찹, 올리고당, 굴소스를 넣습니다.',
      '소스가 잘 배어들 때까지 볶습니다.'
    ]),
    Recipe('콘치즈', ['옥수수', '치즈', '마요네즈'], '횟집 맛', [
      '옥수수 통조림의 물기를 뺍니다.',
      '옥수수와 마요네즈, 설탕을 섞습니다.',
      '팬이나 오븐 용기에 깔고 모짜렐라 치즈를 듬뿍 올립니다.',
      '치즈가 녹을 때까지 가열합니다.'
    ]),
  ];

  // D-Day 계산 함수 (유통기한 없으면 '미등록' 처리)
  String _calculateDday(dynamic expiresAt) {
    if (expiresAt == null || expiresAt == '미등록') return 'D-?';

    // Timestamp 타입이 아닐 경우(예: 문자열) 처리
    if (expiresAt is! Timestamp) return 'D-?';

    final DateTime expiresDate = expiresAt.toDate();
    final DateTime now = DateTime.now();
    final DateTime dateOnlyExpires = DateTime(expiresDate.year, expiresDate.month, expiresDate.day);
    final DateTime dateOnlyNow = DateTime(now.year, now.month, now.day);
    final int difference = dateOnlyExpires.difference(dateOnlyNow).inDays;

    if (difference < 0) {
      return 'D+${difference.abs()}';
    } else if (difference == 0) {
      return 'D-Day';
    } else {
      return 'D-$difference';
    }
  }

  // 재료 삭제 함수
  void _deleteIngredient(String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('재료 삭제'),
        content: Text("'$name'을(를) 냉장고에서 뺄까요?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('refrigerator')
                  .doc(docId)
                  .delete();

              setState(() {
                _selectedItemIds.remove(docId);
                _selectedItemNames.remove(name);
              });

              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _recommendRecipes() {
    if (_selectedItemNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재료를 하나 이상 선택해주세요!')),
      );
      return;
    }

    final recommended = _allRecipes.where((recipe) {
      final recipeIngredients = recipe.requiredIngredients.toSet();
      // 교집합이 있으면 추천
      return recipeIngredients.intersection(_selectedItemNames).isNotEmpty;
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeSearchPage(
          title: "추천 레시피",
          recipes: recommended,
          searchQuery: "선택한 재료: ${_selectedItemNames.join(', ')}",
        ),
      ),
    );
  }

  void _searchRecipes(String query) {
    if (query.isEmpty) return;

    final searchResults = _allRecipes.where((recipe) {
      return recipe.name.contains(query) ||
          recipe.requiredIngredients.contains(query);
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeSearchPage(
          title: "검색 결과",
          recipes: searchResults,
          searchQuery: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('나의 냉장고', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('refrigerator')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('createdAt', descending: true) // 최신순 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }

          final List<QueryDocumentSnapshot> items = snapshot.data?.docs ?? [];
          final List<QueryDocumentSnapshot> urgentItems = [];
          final List<QueryDocumentSnapshot> normalItems = [];

          final DateTime now = DateTime.now();

          // 유통기한별 분류 로직
          for (var item in items) {
            final data = item.data() as Map<String, dynamic>;

            // 유통기한 필드가 있고, Timestamp 타입인 경우에만 계산
            if (data.containsKey('expiresAt') && data['expiresAt'] is Timestamp) {
              final DateTime expiresDate = (data['expiresAt'] as Timestamp).toDate();
              final int difference = expiresDate.difference(now).inDays;

              // 7일 이내면 임박 상품
              if (difference <= 7) {
                urgentItems.add(item);
              } else {
                normalItems.add(item);
              }
            } else {
              // 유통기한 미등록 상품은 일반 리스트로
              normalItems.add(item);
            }
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              // --- 상단 검색창 ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _searchRecipes,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: '양파로 만드는 요리...',
                    icon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '"재료를 체크하고 하단 버튼을 눌러보세요! 추천 요리를 알려드려요."',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // --- 태그 ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTag('인기', isSelected: true),
                    const SizedBox(width: 8),
                    _buildTag('오늘은 내가 요리왕'),
                    const SizedBox(width: 8),
                    _buildTag('#버섯볶음'),
                    const SizedBox(width: 8),
                    _buildTag('#간장계밥'),
                    const SizedBox(width: 8),
                    _buildTag('#냉장고털이'),
                    const SizedBox(width: 8),
                    _buildTag('#초간단레시피'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100.0),
                    child: Column(
                      children: [
                        Icon(Icons.kitchen, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('냉장고가 비어있습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('영수증 스캔으로 재료를 채워보세요!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

              if (items.isNotEmpty) ...[
                // 1. 유통기한 임박 섹션 (있을 때만 표시)
                if (urgentItems.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.redAccent[100], size: 12),
                      const SizedBox(width: 8),
                      Text(
                        '유통기한 임박! (${urgentItems.length}개)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...urgentItems.map((item) {
                    final data = item.data() as Map<String, dynamic>;
                    final String name = data['name'] ?? '알 수 없음';
                    final dynamic expiresAt = data['expiresAt'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildUrgentItemCard(
                          id: item.id,
                          name: name,
                          dDay: _calculateDday(expiresAt)
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // 2. 전체보기 섹션
                ExpansionTile(
                  title: Text(
                    '나의 식재료 (${normalItems.length}개)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  initiallyExpanded: true,
                  iconColor: Colors.black,
                  collapsedIconColor: Colors.black,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 12),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  shape: const Border(),
                  children: [
                    if (normalItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text('보관 중인 재료가 없습니다.', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...normalItems.map((item) {
                        final data = item.data() as Map<String, dynamic>;
                        final String name = data['name'] ?? '알 수 없음';
                        final dynamic expiresAt = data['expiresAt']; // 없을 수도 있음

                        return _buildNormalItemCard(
                            id: item.id,
                            name: name,
                            dDay: _calculateDday(expiresAt)
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 80), // 하단 버튼 공간 확보
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recommendRecipes,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.restaurant),
        label: const Text("선택한 재료로 요리 추천"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- Helper Widgets ---

  Widget _buildTag(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        String query = label.replaceAll('#', '').trim();
        if (query == '인기' || query == '오늘은 내가 요리왕') return;
        _searchRecipes(query);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 임박 상품 카드
  Widget _buildUrgentItemCard({required String id, required String name, required String dDay}) {
    final bool isSelected = _selectedItemIds.contains(id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedItemIds.remove(id);
            _selectedItemNames.remove(name);
          } else {
            _selectedItemIds.add(id);
            _selectedItemNames.add(name);
          }
        });
      },
      onLongPress: () => _deleteIngredient(id, name),

      child: Card(
        elevation: 2.0,
        shadowColor: Colors.red[100],
        color: isSelected ? Colors.red[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: isSelected ? const BorderSide(color: Colors.redAccent, width: 2.0) : BorderSide(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dDay,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.redAccent, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // 일반 상품 카드
  Widget _buildNormalItemCard({required String id, required String name, required String dDay}) {
    final bool isSelected = _selectedItemIds.contains(id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedItemIds.remove(id);
            _selectedItemNames.remove(name);
          } else {
            _selectedItemIds.add(id);
            _selectedItemNames.add(name);
          }
        });
      },
      onLongPress: () => _deleteIngredient(id, name),

      child: Card(
        elevation: 0,
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: isSelected ? const BorderSide(color: Colors.blueAccent, width: 2.0) : BorderSide.none,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.kitchen, color: Colors.blueGrey),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.blueAccent, size: 24)
              : Text(dDay, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      ),
    );
  }
}

// -----------------------------------------------
// [ 3. 검색 결과 & 레시피 상세 페이지는 기존과 동일 ]
// -----------------------------------------------
// ... (RecipeSearchPage, RecipeDetailPage 코드는 기존과 동일하므로 생략하지 않고 아래에 붙여넣습니다)

class RecipeSearchPage extends StatelessWidget {
  final String title;
  final String searchQuery;
  final List<Recipe> recipes;

  const RecipeSearchPage({super.key, required this.title, required this.searchQuery, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Text(
              "'$searchQuery' 결과: 총 ${recipes.length}건",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),

          Expanded(
            child: recipes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("검색 결과가 없습니다.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("돌아가기"),
                  )
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.yellow[50], // 연한 노란색 배경
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.restaurant, color: Colors.amber),
                      ),
                      title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(recipe.description, style: const TextStyle(color: Colors.grey)),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_menu, size: 60, color: Colors.amber),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                recipe.description,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            const Text("준비 재료", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: recipe.requiredIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
            const Divider(height: 40, thickness: 1),
            const Text("조리 순서", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipe.cookingSteps.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recipe.cookingSteps[index],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}