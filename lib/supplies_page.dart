import 'package:flutter/material.dart';

// -----------------------------------------------
// [ 데이터 모델 ]
// -----------------------------------------------
class Party {
  final String title;
  final String location;
  final String status;
  final Color statusColor;
  final bool isUserCreated;

  Party({
    required this.title,
    required this.location,
    required this.status,
    required this.statusColor,
    this.isUserCreated = false,
  });
}

// -----------------------------------------------
// [ 1. 새 파티 모집 화면 (입력 폼) ]
// -----------------------------------------------
class NewPartyPage extends StatefulWidget {
  const NewPartyPage({super.key});

  @override
  State<NewPartyPage> createState() => _NewPartyPageState();
}

class _NewPartyPageState extends State<NewPartyPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = '공동구매';
  double _memberCount = 2;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 파티 모집'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildCategoryChip('공동구매'),
                const SizedBox(width: 10),
                _buildCategoryChip('배달팟'),
                const SizedBox(width: 10),
                _buildCategoryChip('기타'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('제목', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '예) 휴지 30롤 반띵 하실 분',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('모집 인원', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_memberCount.toInt()}명', style: const TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _memberCount,
              min: 2,
              max: 10,
              divisions: 8,
              activeColor: Colors.blueAccent,
              label: '${_memberCount.toInt()}명',
              onChanged: (value) {
                setState(() {
                  _memberCount = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('상세 내용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '장소, 시간, 가격 등 자세한 내용을 적어주세요.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isEmpty) return;
                  Navigator.pop(context, Party(
                    title: _titleController.text,
                    location: '내 위치 (방금)',
                    status: '1/${_memberCount.toInt()} 모집중',
                    statusColor: Colors.blueAccent,
                    isUserCreated: true,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('등록하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}

// -----------------------------------------------
// [ 2. 나의 생필품 메인 화면 ]
// -----------------------------------------------
class SuppliesPage extends StatefulWidget {
  const SuppliesPage({super.key});

  @override
  State<SuppliesPage> createState() => _SuppliesPageState();
}

class _SuppliesPageState extends State<SuppliesPage> {
  // 0: 공동구매, 1: 지출분석, 2: 최저가, 3: 청소, 4: 구독, 5: 자취꿀템(NEW)
  int _selectedMenuIndex = 0;

  final List<Party> _allParties = [
    Party(title: '같이 시키실분 구해요!!', location: '영등포구 1시간전', status: '2/3 모집중', statusColor: Colors.blueAccent),
    Party(title: '냉동만두 5봉 나눠서 사실분?', location: '도림동 3시간전', status: '4/5 모집중', statusColor: Colors.blueAccent),
    Party(title: '정수기 필터 공동구매해요~!', location: '당산동 12시간전', status: '모집완료!', statusColor: Colors.grey),
  ];

  List<Party> _filteredParties = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredParties = _allParties;
  }

  void _runFilter(String enteredKeyword) {
    List<Party> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allParties;
    } else {
      results = _allParties
          .where((party) => party.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredParties = results;
    });
  }

  void _deleteParty(Party party) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('정말 이 글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              setState(() {
                _allParties.remove(party);
                _runFilter(_searchController.text);
              });
              Navigator.pop(ctx);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('나의 생필품', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 검색창
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.0)),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _runFilter(value),
                        decoration: const InputDecoration(
                          hintText: '휴지 공동구매 파티원 모집...',
                          icon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      '"똑 떨어진 건 없나요? 커뮤니티에서 자취 꿀템을 찾아보세요!"',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // [태그 리스트]
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTag('인기', 0), // 공동구매(기본)
                          const SizedBox(width: 12),
                          _buildTag('#가성비', 0), // 클릭 안됨
                          const SizedBox(width: 12),
                          _buildTag('#자취꿀템', 5), // 클릭 됨
                          const SizedBox(width: 12),
                          // #공동구매 삭제됨
                          _buildTag('#최저가', 2), // 클릭 안됨 (최저가 페이지는 아이콘으로 이동)
                          const SizedBox(width: 12),
                          _buildTag('#지출분석', 1), // 클릭 안됨
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // [5가지 아이콘 메뉴]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIconMenuItem(index: 0, icon: Icons.flash_on, label: '공동구매', color: Colors.orange),
                        _buildIconMenuItem(index: 1, icon: Icons.analytics_outlined, label: '지출분석', color: Colors.redAccent),
                        _buildIconMenuItem(index: 2, icon: Icons.shopping_cart_outlined, label: '최저가비교', color: Colors.amber),
                        _buildIconMenuItem(index: 3, icon: Icons.cleaning_services_outlined, label: '청소', color: Colors.blueAccent),
                        _buildIconMenuItem(index: 4, icon: Icons.calendar_today_outlined, label: '정기구독', color: Colors.purple),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Divider(color: Color(0xFFF0F0F0), thickness: 1),
                    ),

                    // 하단 컨텐츠 영역
                    _buildSelectedContent(),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedMenuIndex) {
      case 0: return _buildGroupBuyingContent();
      case 1: return _buildExpenseContent();
      case 2: return _buildPriceCompareContent();
      case 3: return _buildCleaningContent();
      case 4: return _buildSubscriptionContent();
      case 5: return _buildHoneyTipsContent(); // [NEW] 자취꿀템
      default: return _buildGroupBuyingContent();
    }
  }

  // [NEW] 5. 자취 꿀템 컨텐츠
  Widget _buildHoneyTipsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('삶의 질 수직상승! 자취 꿀템 🍯', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('선배 자취러들이 강추하는 아이템만 모았어요.', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 20),

        _buildHoneyTipItem(
            "미니 건조기",
            "좁은 원룸에서도 뽀송하게! 장마철 필수템 1위",
            "189,000원",
            Icons.sunny,
            Colors.orange
        ),
        _buildHoneyTipItem(
            "규조토 발매트",
            "빨래할 필요 없는 초강력 흡수 매트",
            "9,900원",
            Icons.water_drop,
            Colors.blue
        ),
        _buildHoneyTipItem(
            "매직캔 휴지통",
            "냄새 차단 끝판왕, 벌레 꼬임 방지",
            "24,500원",
            Icons.delete_outline,
            Colors.green
        ),
        _buildHoneyTipItem(
            "스탠딩 다리미판",
            "허리 굽히지 않고 편하게 다림질",
            "32,000원",
            Icons.checkroom,
            Colors.purple
        ),
      ],
    );
  }

  Widget _buildHoneyTipItem(String title, String desc, String price, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // 0. 공동구매 컨텐츠
  Widget _buildGroupBuyingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '근처 파티원 찾고 배송비도 아끼고\n상품을 원하는 만큼만 구매해보세요!',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('배송비 아끼는 꿀팁, 파티원 모집', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('${_filteredParties.length}개', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('현재 모집중인 파티', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _filteredParties.length + 1,
                itemBuilder: (context, index) {
                  if (index == _filteredParties.length) {
                    return GestureDetector(
                      onTap: () async {
                        final newParty = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NewPartyPage()),
                        );
                        if (newParty != null && newParty is Party) {
                          setState(() {
                            _allParties.add(newParty);
                            _searchController.clear();
                            _runFilter('');
                          });
                        }
                      },
                      child: _buildNewPartyCardButton(),
                    );
                  }
                  return _buildPartyCard(_filteredParties[index]);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 1. 지출분석 컨텐츠
  Widget _buildExpenseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이번 달 생필품 지출 💸', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('11월 총 지출', style: TextStyle(fontSize: 14, color: Colors.redAccent)),
              const SizedBox(height: 8),
              const Text('245,800원', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: 0.7, backgroundColor: Colors.red[100], color: Colors.redAccent, minHeight: 10, borderRadius: BorderRadius.circular(5)),
              const SizedBox(height: 8),
              const Text('예산(35만원)의 70%를 사용했어요!', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text('고정 지출 관리 (구독)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildSubItem('넷플릭스', '17,000원', '매월 5일 결제', 'D-5', Colors.red),
        _buildSubItem('쿠팡 와우', '4,990원', '매월 12일 결제', 'D-12', Colors.blue),
        _buildSubItem('유튜브 프리미엄', '14,900원', '매월 20일 결제', 'D-20', Colors.redAccent),
      ],
    );
  }

  // 2. 최저가비교 컨텐츠
  Widget _buildPriceCompareContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('자취 필수템 최저가 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPriceItem('삼다수 2L x 6개', '4,980원', '쿠팡', true),
        _buildPriceItem('크리넥스 30롤', '18,900원', '네이버', false),
        _buildPriceItem('햇반 210g x 12개', '11,500원', '티몬', true),
        _buildPriceItem('다우니 1L', '6,500원', '11번가', false),
      ],
    );
  }

  // 3. 청소 컨텐츠
  Widget _buildCleaningContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('오늘의 청소 미션 🧹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blueAccent, size: 40),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('환기 시키기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('아침에 10분만 창문 열어두세요!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('주간 청소 체크리스트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        CheckboxListTile(value: true, onChanged: (v){}, title: const Text('화장실 물때 제거'), activeColor: Colors.blueAccent),
        CheckboxListTile(value: false, onChanged: (v){}, title: const Text('침구 털기 및 햇볕 소독')),
      ],
    );
  }

  // 4. 정기구독 (멤버십) 컨텐츠
  Widget _buildSubscriptionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("자취생존 멤버십", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("배달비, 배송비 걱정 끝!", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text("월 2,900원", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Text("(첫 달 무료)", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("지금 무료로 시작하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text("멤버십 혜택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildBenefitItem(Icons.local_shipping, "공동구매 배송비 무료", "모든 공동구매 참여 시 배송비가 0원입니다."),
        _buildBenefitItem(Icons.delivery_dining, "배달팁 무제한 할인", "연동된 배달앱에서 배달팁 2,000원 할인 쿠폰 지급"),
        _buildBenefitItem(Icons.store, "편의점 10% 할인", "GS25, CU 도시락 상시 10% 할인"),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildBenefitItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
            child: Icon(icon, color: Colors.purple, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSubItem(String name, String price, String date, String dDay, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.payment, color: color)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(dDay, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String name, String price, String shop, bool isLowest) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$shop | 배송비 무료'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            if (isLowest)
              const Text('최저가', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // [수정됨]
  // 1. '인기'와 '#자취꿀템'만 클릭 가능
  // 2. '#가성비'는 클릭 불가능 + 선택된 색상(회색)도 안 나옴
  Widget _buildTag(String label, int targetIndex) {

    // 클릭 가능한지 확인 (인기, 자취꿀템만 가능)
    bool isClickable = (label == '인기' || label == '#자취꿀템');

    // 선택된 상태인지 확인 (현재 메뉴 인덱스와 같고 + 클릭 가능한 녀석이어야 함)
    // -> 이렇게 하면 '#가성비'는 targetIndex가 0이어도 isClickable이 false라서 선택된 효과가 안 나옵니다.
    bool isSelected = isClickable && (_selectedMenuIndex == targetIndex);

    return GestureDetector(
      onTap: isClickable
          ? () {
        setState(() {
          _selectedMenuIndex = targetIndex;
        });
      }
          : null, // 클릭 불가능하면 null (반응 없음)
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEEEEE) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.grey[400]!) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildIconMenuItem({required int index, required IconData icon, required String label, required Color color}) {
    final bool isSelected = _selectedMenuIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenuIndex = index;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.05),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: color, width: 2) : null,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPartyCard(Party party) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (!party.isUserCreated) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("샘플 파티는 수정할 수 없습니다.")));
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, spreadRadius: 1)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(party.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(party.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: party.statusColor == Colors.grey ? Colors.grey[100] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        party.status,
                        style: TextStyle(
                            color: party.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (party.isUserCreated)
          Positioned(top: 8, right: 8, child: GestureDetector(onTap: () => _deleteParty(party), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.grey)))),
      ],
    );
  }

  Widget _buildNewPartyCardButton() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16.0)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('새 파티 모집', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)), const SizedBox(height: 4), const Text('상품 등록', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 12), Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]), child: const Icon(Icons.add, color: Colors.blueAccent, size: 28))]),
    );
  }
}