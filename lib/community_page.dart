import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // 선택된 카테고리 인덱스 (0: 전체)
  int _selectedCategoryIndex = 0;

  // 카테고리 목록
  final List<String> _categories = [
    "전체",
    "🍚 요리/식단",
    "💰 돈관리",
    "🧹 청소/꿀팁",
    "🫂 자취고민",
  ];

  // 게시글 더미 데이터 (요청하신 주제 반영)
  final List<Map<String, String>> _posts = [
    {
      "category": "🍚 요리/식단",
      "title": "냉장고에 양파밖에 없는데 오늘 저녁 뭐 먹죠? 😭",
      "content": "진짜 양파랑 계란 딱 두 개 있어요... 볶음밥 말고 다른 거 추천 좀 해주세요 배고파요",
      "author": "배고픈자취생",
      "time": "10분 전",
      "likes": "5",
      "comments": "12"
    },
    {
      "category": "🫂 자취고민",
      "title": "퇴근하고 집에 왔는데 불 켜는 게 제일 쓸쓸해요...",
      "content": "다들 이럴 때 어떻게 극복하시나요? 적막감이 너무 싫어서 TV부터 켜네요.",
      "author": "새벽감성",
      "time": "1시간 전",
      "likes": "24",
      "comments": "8"
    },
    {
      "category": "🧹 청소/꿀팁",
      "title": "혼자 사는 분들 방에 곰팡이 안 생기게 하는 습관 공유 좀",
      "content": "환기를 시킨다고 하는데도 구석에 자꾸 생기네요 ㅠㅠ 제습기 필수인가요?",
      "author": "곰팡이싫어",
      "time": "2시간 전",
      "likes": "15",
      "comments": "21"
    },
    {
      "category": "💰 돈관리",
      "title": "이번 달 생활비 15만 원 남았는데 버틸 수 있을까요?",
      "content": "월급날까지 10일 남았습니다... 강제 다이어트 시작해야 하나요. 식비 아끼는 꿀팁 좀요.",
      "author": "텅장요정",
      "time": "3시간 전",
      "likes": "42",
      "comments": "30"
    },
    {
      "category": "💰 돈관리",
      "title": "쿠팡 와우 vs 네이버 플러스, 자취생에게 뭐가 더 이득?",
      "content": "둘 다 쓰기엔 좀 아까워서 하나만 쓰려는데 자취생 입장에서 뭐가 더 혜택이 쏠쏠한가요?",
      "author": "스마트컨슈머",
      "time": "5시간 전",
      "likes": "8",
      "comments": "15"
    },
    {
      "category": "🍚 요리/식단",
      "title": "혼자서 1주일 만에 다 먹는 소분 꿀팁 레시피 공유",
      "content": "대파랑 마늘 한 번 사면 다 못 먹고 버리는 분들 필독! 이렇게 얼려두면 3달은 먹습니다.",
      "author": "냉장고마스터",
      "time": "어제",
      "likes": "102",
      "comments": "45"
    },
    {
      "category": "🧹 청소/꿀팁",
      "title": "다 쓴 건전지랑 형광등은 어디에 버리세요?",
      "content": "그냥 종량제 봉투에 넣으면 안 되죠? 동네마다 다른가요?",
      "author": "분리수거초보",
      "time": "어제",
      "likes": "3",
      "comments": "5"
    },
    {
      "category": "🫂 자취고민",
      "title": "이웃집 소음 때문에 미치겠습니다. 쪽지 써야 할까요?",
      "content": "밤마다 쿵쿵대는데 올라가서 말하기는 무섭고 쪽지 붙이면 기분 나빠할까요?",
      "author": "잠좀자자",
      "time": "2일 전",
      "likes": "56",
      "comments": "60"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '커뮤니티',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- 1. 카테고리 선택 영역 ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: _selectedCategoryIndex == index,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      selectedColor: Colors.blue[50],
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedCategoryIndex == index
                            ? Colors.blueAccent
                            : Colors.grey[600],
                        fontWeight: _selectedCategoryIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedCategoryIndex == index
                              ? Colors.blueAccent
                              : Colors.grey[300]!,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),
          ),

          // --- 2. 게시글 리스트 ---
          Expanded(
            child: Container(
              color: Colors.grey[50], // 배경색 살짝 회색
              child: ListView.separated(
                itemCount: _posts.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Color(0xFFEEEEEE),
                ),
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return _buildPostItem(post);
                },
              ),
            ),
          ),
        ],
      ),
      // 글쓰기 플로팅 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 화면 이동 (추후 구현)
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.edit),
      ),
    );
  }

  // 게시글 아이템 위젯
  Widget _buildPostItem(Map<String, String> post) {
    return InkWell(
      onTap: () {
        // 상세 페이지 이동 (추후 구현)
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                post['category']!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            // 제목
            Text(
              post['title']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // 내용 미리보기
            Text(
              post['content']!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // 하단 정보 (작성자, 시간, 좋아요, 댓글)
            Row(
              children: [
                Text(
                  post['author']!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                const Text('·', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 4),
                Text(
                  post['time']!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                // 좋아요
                const Icon(Icons.thumb_up_alt_outlined,
                    size: 14, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                  post['likes']!,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
                const SizedBox(width: 12),
                // 댓글
                const Icon(Icons.chat_bubble_outline,
                    size: 14, color: Colors.blueAccent),
                const SizedBox(width: 4),
                Text(
                  post['comments']!,
                  style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}