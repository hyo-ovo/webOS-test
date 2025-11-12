import 'package:flutter/material.dart';
import '../logic/auth_controller.dart';

class FaceLoginWidget extends StatefulWidget {
  final bool isRegistration;
  final String? username;
  final bool isChild;

  const FaceLoginWidget({
    Key? key,
    required this.isRegistration,
    this.username,
    this.isChild = false,
  }) : super(key: key);

  @override
  State<FaceLoginWidget> createState() => _FaceLoginWidgetState();
}

class _FaceLoginWidgetState extends State<FaceLoginWidget>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = AuthController();
  bool _isProcessing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleFaceRecognition() async {
    try {
      setState(() => _isProcessing = true);

      if (widget.isRegistration) {
        final user = await _authController.registerUser(
          widget.username!,
          widget.isChild,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // 회원가입 완료 후 홈 화면으로 이동 (추후 구현)
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        await _authController.loginWithFace(username: widget.username!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: Colors.green,
          ),
        );

        // 로그인 완료 후 홈 화면으로 이동 (추후 구현)
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBBBBB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isRegistration ? '얼굴 등록' : '얼굴 인식 로그인',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.username ?? '',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 60),

            // 얼굴 인식 아이콘
            GestureDetector(
              onTap: _isProcessing ? null : _handleFaceRecognition,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200 + (_pulseController.value * 20),
                    height: 200 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4A90E2),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.5),
                          blurRadius: 20 + (_pulseController.value * 10),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: _isProcessing
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4A90E2),
                              strokeWidth: 4,
                            ),
                          )
                        : const Icon(
                            Icons.face,
                            size: 100,
                            color: Color(0xFF4A90E2),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),

            Text(
              _isProcessing
                  ? '처리 중...'
                  : widget.isRegistration
                      ? '화면을 터치하여 얼굴을 등록하세요'
                      : '화면을 터치하여 로그인하세요',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            if (!_isProcessing) ...[
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: _handleFaceRecognition,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  widget.isRegistration ? '얼굴 등록' : '얼굴 인식',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
