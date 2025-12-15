import 'package:flutter/material.dart';

class RecyclingSetupPage extends StatefulWidget {
  const RecyclingSetupPage({super.key});

  @override
  State<RecyclingSetupPage> createState() => _RecyclingSetupPageState();
}

class _RecyclingSetupPageState extends State<RecyclingSetupPage> {
  // 요일 목록
  final List<String> _days = ['월', '화', '수', '목', '금', '토', '일'];

  // 분리수거 항목 목록
  final List<String> _wasteTypes = [
    '일반쓰레기', '음식물', '플라스틱', '캔/고철',
    '유리병', '종이', '비닐', '의류/잡화'
  ];

  // 선택된 요일 (기본값: 월요일)
  int _selectedDayIndex = 0;

  // 데이터 저장소: { '월': ['플라스틱', '비닐'], '화': [], ... }
  final Map<String, List<String>> _schedule = {
    '월': [], '화': [], '수': [], '목': [], '금': [], '토': [], '일': []
  };

  // 알림 시간
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  void _toggleWasteType(String type) {
    setState(() {
      final day = _days[_selectedDayIndex];
      if (_schedule[day]!.contains(type)) {
        _schedule[day]!.remove(type);
      } else {
        _schedule[day]!.add(type);
      }
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            colorScheme: const ColorScheme.light(primary: Colors.green),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = _days[_selectedDayIndex];
    final selectedWastes = _schedule[currentDay]!;

    return Scaffold(
      backgroundColor: Colors.green[50], // [디자인] 연한 초록색 배경
      appBar: AppBar(
        title: const Text("분리수거 알림 설정", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 안내 문구
                    const Text(
                      "우리 동네 배출 요일을\n선택해주세요! 🌿",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "설정한 요일에 맞춰 알림을 보내드릴게요.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // 2. 요일 선택 (가로 스크롤 혹은 고정)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_days.length, (index) {
                          final isSelected = _selectedDayIndex == index;
                          final hasData = _schedule[_days[index]]!.isNotEmpty;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDayIndex = index;
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.green : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _days[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // 데이터가 있으면 작은 점 표시
                                Icon(Icons.circle, size: 6, color: hasData ? Colors.green : Colors.transparent),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 3. 품목 선택 (그리드)
                    Text(
                      "$currentDay요일 배출 품목",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 한 줄에 2개
                        childAspectRatio: 2.5, // 납작한 모양
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _wasteTypes.length,
                      itemBuilder: (context, index) {
                        final type = _wasteTypes[index];
                        final isChecked = selectedWastes.contains(type);

                        return GestureDetector(
                          onTap: () => _toggleWasteType(type),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isChecked ? Colors.green : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isChecked ? Colors.green : Colors.green.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (!isChecked)
                                  BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isChecked ? Icons.check_circle : Icons.circle_outlined,
                                  color: isChecked ? Colors.white : Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type,
                                  style: TextStyle(
                                    color: isChecked ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // 4. 알림 시간 설정
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("알림 시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("배출일 당일 오전에 알려드려요", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _selectTime(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green[50],
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              _notificationTime.format(context),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. 완료 버튼
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // [나중] 여기서 파이어베이스 저장 로직 추가
                    print("저장된 스케줄: $_schedule");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("알림 설정이 저장되었습니다! 🌱"), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: const Text(
                    "설정 완료",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}