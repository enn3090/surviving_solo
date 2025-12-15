import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'manual_input_page.dart';
import 'scan_result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isScanning = false; // ★ 로딩 상태 변수 추가
  TextRecognizer? _textRecognizer;

  @override
  void initState() {
    super.initState();
    // 한국어 스크립트 설정
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.veryHigh, // ★ 해상도를 'veryHigh'로 높임 (인식률 향상)
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      // ★ [중요] 자동 초점 모드 설정 (흐릿함 방지)
      await _controller!.setFocusMode(FocusMode.auto);

      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('카메라 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer?.close();
    super.dispose();
  }

  Future<void> _takePictureAndRecognizeText() async {
    // 카메라가 없거나 이미 스캔 중이면 무시
    if (_controller == null || !_controller!.value.isInitialized || _isScanning) {
      return;
    }

    // ★ 로딩 시작
    setState(() {
      _isScanning = true;
    });

    try {
      final XFile imageFile = await _controller!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      // OCR 인식 수행
      final RecognizedText recognizedText = await _textRecognizer!.processImage(inputImage);

      debugPrint('--- [ OCR 인식 결과 ] ---');
      debugPrint(recognizedText.text);
      debugPrint('-----------------------');

      if (!mounted) return;

      // 결과 페이지로 이동
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultPage(rawText: recognizedText.text),
        ),
      );
    } catch (e) {
      debugPrint('에러 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("인식에 실패했습니다. 다시 시도해주세요.")),
        );
      }
    } finally {
      // ★ 로딩 끝
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('영수증 스캔'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. 카메라 미리보기
          _isCameraInitialized
              ? Positioned.fill(child: CameraPreview(_controller!))
              : const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. 가이드라인
          Positioned(
            top: 16, left: 0, right: 0,
            child: Column(
              children: [
                const Text('영수증을 가이드라인에 맞춰 촬영해주세요.',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 40),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),

          // 3. 하단 버튼
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 80),

                // ★ 촬영 버튼 (로딩 중엔 뺑글이)
                GestureDetector(
                  onTap: _takePictureAndRecognizeText,
                  child: _isScanning
                      ? const SizedBox(
                    width: 70, height: 70,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ),

                // 직접 입력 버튼
                SizedBox(
                  width: 50,
                  child: TextButton(
                    onPressed: _isScanning
                        ? null
                        : () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManualInputPage())),
                    child: Text('직접 입력', style: TextStyle(color: _isScanning ? Colors.grey : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}