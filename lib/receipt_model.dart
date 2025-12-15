// 영수증에 찍힌 개별 품목 데이터 모델
class ReceiptItem {
  String name;      // 상품명 (예: 우유, 계란)
  int price;        // 가격
  bool isSelected;  // 선택 여부 (체크박스용) [cite: 131]

  ReceiptItem({required this.name, required this.price, this.isSelected = true});
}