import 'package:flutter/material.dart';
import '../logic/auth_controller.dart';
import '../data/user_model.dart';
import 'account_selection_screen.dart';

/// 비밀번호 입력 화면 - 회원가입/로그인
class FaceLoginWidget extends StatefulWidget {
  final bool isRegistration; // true: 회원가입, false: 로그인
  final String? username;
  final bool isChild;
  final String? characterImagePath; // 선택한 빈버드 캐릭터 이미지 경로 (회원가입 시)

  const FaceLoginWidget({
    Key? key,
    required this.isRegistration,
    this.username,
    this.isChild = false,
    this.characterImagePath,
  }) : super(key: key);

  @override
  State<FaceLoginWidget> createState() => _FaceLoginWidgetState();
}

class _FaceLoginWidgetState extends State<FaceLoginWidget> {
  final AuthController _authController = AuthController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      if (widget.isRegistration) {
        // 회원가입
        final user = await _authController.signup(
          name: widget.username!,
          password: _passwordController.text.trim(),
          isChild: widget.isChild,
        );

        // 캐릭터 이미지 경로가 있으면 추가하여 저장
        if (widget.characterImagePath != null) {
          final userWithCharacter = UserModel(
            id: user.id,
            username: user.username,
            token: user.token,
            isChild: user.isChild,
            characterImagePath: widget.characterImagePath,
          );
          await _authController.saveUserToLocalStorage(userWithCharacter);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // 회원가입 완료 후 저장된 사용자 목록을 불러와서 계정 선택 화면으로 이동
        final updatedUsers = await _authController.getStoredUsers();
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AccountSelectionScreen(users: updatedUsers),
          ),
        );
      } else {
        // 로그인
        final user = await _authController.login(
          name: widget.username!,
          password: _passwordController.text.trim(),
        );

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

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: ${_errorMessage ?? e.toString()}'),
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
    // 피그마 디자인 토큰
    const Color bgColor = Color(0xFFC3C3C3);
    const Color textColor = Color(0xFF6B6B6B);
    const Color inputBgColor = Color(0xFFF4F5F5);
    const Color white = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목
                Text(
                  widget.isRegistration ? '비밀번호 설정' : '비밀번호 입력',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 28,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.username ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),

                // 비밀번호 입력 필드
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isProcessing,
                  decoration: InputDecoration(
                    labelText: widget.isRegistration ? '비밀번호를 입력하세요' : '비밀번호를 입력하세요',
                    labelStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      color: textColor,
                    ),
                    filled: true,
                    fillColor: inputBgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: textColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (widget.isRegistration && value.trim().length < 4) {
                      return '비밀번호는 4자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),

                // 에러 메시지 표시 영역 (고정 높이)
                SizedBox(
                  height: 24,
                  child: _errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              color: Colors.redAccent,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 40),

                // 제출 버튼
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      foregroundColor: white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(white),
                            ),
                          )
                        : Text(
                            widget.isRegistration ? '회원가입' : '로그인',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* 
 * TODO: 얼굴 인식 기능은 나중에 구현 예정
 * 
 * 얼굴 인식 기반 회원가입/로그인 기능:
 * - webOS 카메라 API를 사용하여 얼굴 사진 촬영
 * - 얼굴 특징 추출 및 인코딩
 * - 백엔드 API로 얼굴 데이터 전송
 * - 백엔드에서 얼굴 인식 및 매칭 처리
 * 
 * 참고: backend.mdc의 얼굴 인식 API 명세 확인 필요
 */
