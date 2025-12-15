import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceiptItem {
  String name;
  int price;
  ReceiptItem({required this.name, required this.price});
  Map<String, dynamic> toMap() => {'name': name, 'price': price};
}

class ScanResultPage extends StatefulWidget {
  final String rawText;
  const ScanResultPage({super.key, required this.rawText});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  String detectedDate = DateTime.now().toString().substring(0, 10);
  List<ReceiptItem> parsedItems = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _parseReceiptData();
  }

  String _formatCurrency(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  int get _totalPrice => parsedItems.fold(0, (sum, item) => sum + item.price);

  void _parseReceiptData() {
    List<String> lines = widget.rawText.split('\n');
    RegExp datePattern = RegExp(r'20\d{2}[-.]\d{2}[-.]\d{2}');

    List<String> nameCandidates = [];
    List<int> priceCandidates = [];

    for (String line in lines) {
      String cleanLine = line.trim();
      if (cleanLine.isEmpty) continue;

      // 1. 날짜 추출
      if (datePattern.hasMatch(cleanLine)) {
        detectedDate = datePattern.firstMatch(cleanLine)!.group(0)!;
        continue;
      }

      // ============================================================
      // [초강력 필터] 잡초 뽑기 (로그에 나온 쓰레기 단어들 저격)
      // ============================================================
      String upper = cleanLine.toUpperCase();

      // 1. 영수증 헤더/푸터/구분선/기타 잡동사니
      if (upper.contains('TEL') || upper.contains('주소') ||
          upper.contains('상호') || upper.contains('테이블') ||
          upper.contains('담당') || upper.contains('번호') ||
          upper.contains('판매원') || upper.contains('시간') ||
          upper.contains('영수') || upper.contains('영스') || // 영스
          upper.contains('품명') || upper.contains('풀명') ||
          upper.contains('수량') || upper.contains('단가') ||
          upper.contains('금액') || upper.contains('할인') ||
          upper.contains('카드') || upper.contains('승인') ||
          upper.contains('결제') || upper.contains('가맹') ||
          upper.contains('WIFI') || upper.contains('PW') ||
          upper.contains('MESH') || upper.contains('KIO') || // Kio 제거
          upper.contains('층') || // 1,2층 제거
          upper.contains('말 부') || // 할부 쪼개진거
          upper.contains('개') || // 개월
          upper.startsWith('---')) {
        continue;
      }

      // 2. 너무 짧은 외계어 (1글자 등) 제거
      // 단, '소', '계' 같은게 이름으로 들어가는 것 방지
      if (cleanLine.length < 2) continue;
      if (cleanLine == '소' || cleanLine == '계' || cleanLine == '면세') continue;

      // 3. 합계 관련 (가격 리스트에 안 넣으려고 제외)
      if (upper.contains('합계') || upper.contains('소계') ||
          upper.contains('부가세') || upper.contains('봉사료') ||
          upper.contains('면세') || upper.contains('과세')) {
        continue;
      }

      // ============================================================
      // [분류] 가격 vs 상품명
      // ============================================================

      String strForPrice = cleanLine.replaceAll(RegExp(r'[^0-9]'), '');
      bool isPriceLine = false;

      if (strForPrice.isNotEmpty) {
        int? val = int.tryParse(strForPrice);

        // [가격 조건]
        // 1. 500원 이상 ~ 200만원 이하
        // 2. 날짜 오인 방지 (8자리 미만)
        if (val != null && val >= 500 && val <= 2000000 && strForPrice.length < 8) {
          // 줄에 콤마가 있거나, 줄 길이가 짧아서(10자 이하) 가격만 덩그러니 있는 경우
          if (cleanLine.contains(',') || cleanLine.length < 10) {
            priceCandidates.add(val);
            isPriceLine = true;
          }
        }
      }

      // 가격이 아니라면 상품명으로 간주
      if (!isPriceLine) {
        // 숫자로만 된 줄("53275011") 제거
        if (!RegExp(r'^[0-9]+$').hasMatch(cleanLine)) {
          // 특수문자만 있는거 제거
          if (cleanLine.replaceAll(RegExp(r'[^a-zA-Z가-힣0-9]'), '').isNotEmpty) {
            nameCandidates.add(cleanLine);
          }
        }
      }
    }

    // ============================================================
    // [보정] 합계 금액 제거 로직 (중복된 큰 금액 제거)
    // ============================================================
    // 보통 영수증 끝에 '합계'가 나와서 가격 리스트 마지막에 큰 금액이 중복됨.
    // 상품 개수보다 가격 개수가 많으면 뒤쪽(합계)을 자름.
    int count = nameCandidates.length;
    if (priceCandidates.length > count) {
      // 가격이 이름보다 많으면, 보통 뒤에 있는게 합계일 확률이 높음 -> 앞에서부터 개수만큼만 씀
      priceCandidates = priceCandidates.sublist(0, count);
    } else {
      // 가격이 모자라면 이름 개수를 가격 개수에 맞춤
      count = priceCandidates.length;
    }

    List<ReceiptItem> tempItems = [];
    for (int i = 0; i < count; i++) {
      String rawName = nameCandidates[i];
      // 앞쪽 숫자나 특수문자 제거 (예: "01. 상품명" -> "상품명")
      String displayName = rawName.replaceAll(RegExp(r'^[0-9]+[\.\s]*'), '');

      tempItems.add(ReceiptItem(name: displayName, price: priceCandidates[i]));
    }

    setState(() {
      parsedItems = tempItems;
    });
  }

  Future<void> _saveToFirebase() async {
    if (parsedItems.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      String uid = user?.uid ?? 'unknown';

      await FirebaseFirestore.instance.collection('receipts').add({
        'uid': uid,
        'date': detectedDate,
        'totalPrice': _totalPrice,
        'items': parsedItems.map((item) => item.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("저장 완료!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("인식 결과 수정")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            width: double.infinity,
            child: Text("📅 $detectedDate", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: parsedItems.isEmpty
                ? const Center(child: Text("메뉴를 찾지 못했습니다."))
                : ListView.separated(
              itemCount: parsedItems.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => setState(() => parsedItems.removeAt(index)),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: parsedItems[index].name,
                          decoration: const InputDecoration(labelText: "상품명", border: OutlineInputBorder()),
                          onChanged: (val) => parsedItems[index].name = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: parsedItems[index].price.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "금액", suffixText: "원", border: OutlineInputBorder()),
                          onChanged: (val) {
                            setState(() {
                              parsedItems[index].price = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("총 합계", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${_formatCurrency(_totalPrice)}원", style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveToFirebase,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("저장하기", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}