# 🏠 자취생존 (Surviving Solo)
> **"혼자서 짊어진 생활 관리의 짐을 덜어주는 스마트 개인 비서"**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android Studio](https://img.shields.io/badge/Android_Studio-3DDC84?style=for-the-badge&logo=android-studio&logoColor=white)

## 📖 프로젝트 개요
**자취생존**은 1인 가구가 겪는 식재료 관리, 생필품 구매, 가사 노동의 부담을 덜어주기 위해 기획된 **올인원 생활 매니지먼트 플랫폼**입니다.
식재료 폐기, 중복 구매 등 불필요한 지출을 막고, 자취생들이 효율적인 소비 습관과 규칙적인 생활 루틴을 형성하도록 돕습니다.

* **개발 기간:** 2024.00.00 ~ 2024.00.00 (기간 수정 필요)
* **개발 인원:** 1인 (기획, 디자인, 개발 전 과정 수행)
* **주요 기능:** 영수증 OCR 스캔, 냉장고 유통기한 관리, 레시피 추천, 생필품 지출 분석 및 공동구매

<br>

## 📱 주요 기능 (Key Features)

### 1. 🧾 영수증 스캔 및 자동 등록 (OCR)
* **Google ML Kit**를 활용하여 영수증을 촬영하면 상품명과 가격을 자동으로 인식합니다.
* 복잡한 수기 입력 없이 냉장고 재료와 가계부를 한 번에 정리할 수 있습니다.

### 2. 🧊 스마트 냉장고 & 유통기한 관리
* 식재료의 D-Day를 실시간으로 계산하고, **'유통기한 임박(7일 이내)'** 상품을 시각적으로 강조합니다.
* 냉장고 속 재료를 기반으로 만들 수 있는 **최적의 레시피를 추천**하여 배달 음식 의존도를 낮춥니다.

### 3. 💰 생필품 지출 분석 & 공동구매
* 월별 생필품 구매 내역을 그래프로 시각화하고, 넷플릭스 등 **구독(고정 지출) 관리** 기능을 제공합니다.
* 이웃과 함께하는 **공동구매 모집** 및 최저가 비교를 통해 합리적인 소비를 돕습니다.

### 4. 🧹 자취 생활 편의 루틴
* 요일별 분리수거 알림, 청소 체크리스트 제공.
* 자취 꿀팁을 공유하는 커뮤니티 기능을 통해 소통 창구를 마련했습니다.

<br>

## 🛠 기술 스택 (Tech Stack)

| 구분 | 기술 | 설명 |
| --- | --- | --- |
| **Framework** | Flutter | Android/iOS 크로스 플랫폼 개발 |
| **Language** | Dart | 비동기 처리 및 UI 구현 |
| **Backend** | Firebase Auth | 이메일/비밀번호 로그인 및 세션 관리 |
| **DB** | Cloud Firestore | NoSQL 기반 실시간 데이터 동기화 및 관리 |
| **Library** | google_mlkit | 텍스트 인식(OCR) 기능 구현 |
| **Library** | camera | 커스텀 카메라 뷰, 줌/포커스 제어 |

<br>

## 🔥 트러블 슈팅 (Troubleshooting)

개발 과정에서 마주친 주요 문제와 해결 과정입니다.

### 1. iOS 환경에서의 한글 OCR 모델 미로드 문제
* **문제:** Android와 달리 iOS 시뮬레이터에서 한글이 깨지거나 인식되지 않는 현상 발생.
* **원인:** iOS의 CocoaPods 설정에서 한국어 모델이 기본으로 포함되지 않음.
* **해결:** `Podfile`에 `pod 'GoogleMLKit/TextRecognitionKorean'`을 명시적으로 추가하고 강제 주입하여 해결.

### 2. 촬영 환경에 따른 인식률 저하
* **문제:** 초점이 흐리거나 거리가 멀 경우 OCR 정확도가 현저히 떨어짐.
* **해결:**
    * `ResolutionPreset.veryHigh`로 카메라 해상도 상향.
    * `setFocusMode(auto)` 및 `setZoomLevel(2.0)`을 기본값으로 설정하여 사용자 경험(UX) 개선.

### 3. 비정형 영수증 데이터 파싱 오류
* **문제:** 영수증의 상호명이나 전화번호가 가격으로 오인식되어 데이터 밀림 현상 발생.
* **해결:** **규칙 기반 후처리 알고리즘** 구현.
    * `RegExp`를 이용해 날짜, 전화번호 등 노이즈 데이터 1차 필터링.
    * 상호, TEL, 합계 등 불용어(Stopwords)가 포함된 라인 제거.
    * 상품명과 가격 리스트의 인덱스를 매칭하고, 유효 범위를 벗어난 가격 데이터 자동 소거.

### 4. Firestore 복합 쿼리 인덱싱 에러
* **문제:** '나의 냉장고' 로딩 시 `The query requires an index` 에러 발생.
* **원인:** `uid`(필터링)와 `createdAt`(정렬) 두 가지 조건을 동시에 쿼리하기 위해 복합 색인 필요.
* **해결:** Firebase Console에서 복합 인덱스를 생성하여 쿼리 성능 최적화.

<br>

## 🚀 향후 계획 (Roadmap)
* **바코드 스캔:** 공공 데이터 API를 연동하여 가공식품 정보 자동 등록.
* **푸시 알림 (FCM):** 유통기한 임박 알림 서비스 구현.
* **위치 기반 공동구매:** 동네 인증을 통한 실시간 공동구매 매칭 시스템.

<br>

## 🧑‍💻 개발자 (Author)
* **이영현 (YeongHyun Lee)**
* **Role:** 기획, 디자인, Frontend, Backend
* **Contact:** (이메일 주소 입력)
