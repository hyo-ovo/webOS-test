import 'package:flutter/material.dart';
import 'face_login_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isChild = false;
  String? _selectedCharacter;
  String? _usernameError; 


  static const Color _bgColor = Color(0xFFE6E6E6); // Sub1 (배경)
  static const Color _textColor = Color(0xFF6B6B6B); // LGGray (텍스트)
  static const Color _iconColor = Color(0xFF7E838C); // Sub3 (아이콘)
  static const Color _fieldBgColor = Color(0xFFF4F5F5); // 입력 필드 배경
  static const Color _white = Color(0xFFFFFFFF); // white

  // Binbird 이미지 경로
  static const List<String> _characterImages = [
    'assets/characters/binbird-1.png',
    'assets/characters/binbird-2.png',
    'assets/characters/binbird-3.png',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _showCharacterSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: _bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5, // 모달 너비를 반으로 줄임
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '캐릭터 선택',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _characterImages.asMap().entries.map((entry) {
                    final imagePath = entry.value;
                    final isSelected = _selectedCharacter == imagePath;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCharacter = imagePath;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 150, // 50% 키움 (100 -> 150)
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? _textColor : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: _fieldBgColor,
                                    child: Icon(
                                      Icons.error_outline,
                                      size: 75,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // 마지막 항목이 아니면 간격 추가
                        if (entry.key < _characterImages.length - 1)
                          const SizedBox(width: 16), // 간격 좁힘
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _proceedToFaceRegistration() {
    if (!_formKey.currentState!.validate()) return;
    
    // TODO: 얼굴 인식 기능은 나중에 구현 예정
    // 얼굴 정보 수집 동의 체크박스는 주석 처리
    // if (!_agreeToTerms) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         '얼굴 정보 수집에 동의해주세요',
    //         style: TextStyle(
    //           fontFamily: 'Pretendard',
    //           fontSize: 16,
    //           color: _white,
    //         ),
    //       ),
    //       backgroundColor: Colors.redAccent,
    //     ),
    //   );
    //   return;
    // }

    // 비밀번호 입력 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FaceLoginWidget(
          isRegistration: true,
          username: _usernameController.text.trim(),
          isChild: _isChild,
          characterImagePath: _selectedCharacter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white, // 피그마 Sub1 색상
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                
                // 빈버드 이미지 선택
                GestureDetector(
                  onTap: _showCharacterSelectionDialog,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: _fieldBgColor, // Sub2 색상 (회색 원형)
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _textColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: _selectedCharacter != null
                        ? ClipOval(
                            child: Image.asset(
                              _selectedCharacter!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error_outline,
                                  size: 50,
                                  color: Colors.red,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 50,
                            color: _iconColor,
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: 350, // 크기 축소
                  child: Column(
                    children: [
                      // 계정 이름 입력 필드
                      Container(
                        height: 50, // 크기 축소
                        decoration: BoxDecoration(
                          color: _fieldBgColor, // Sub2 색상
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: _textColor,
                          ),
                          decoration: InputDecoration(
                            hintText: '계정 이름을 입력해주세요',
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              color: _textColor.withOpacity(0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.edit_outlined,
                              color: _iconColor,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.red.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.red.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            filled: true,
                            fillColor: _fieldBgColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            errorStyle: TextStyle(
                              height: 0,
                              fontSize: 0,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.trim().isEmpty) {
                                _usernameError = '계정 이름을 입력해주세요';
                              } else if (value.trim().length < 2) {
                                _usernameError = '계정 이름은 2자 이상이어야 합니다';
                              } else {
                                _usernameError = null;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '계정 이름을 입력해주세요';
                            }
                            if (value.trim().length < 2) {
                              return '계정 이름은 2자 이상이어야 합니다';
                            }
                            return null;
                          },
                        ),
                      ),
                      // 에러 메시지 표시 영역 (고정 높이)
                      SizedBox(
                        height: 28, // 에러 메시지 공간 고정 (8px padding + 20px 텍스트 높이)
                        child: _usernameError != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8, left: 12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _usernameError!,
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      color: Colors.red,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 32),
                      
                      // 아동용 계정 체크박스
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32, // 크기 축소
                            height: 32,
                            child: Checkbox(
                              value: _isChild,
                              onChanged: (value) => setState(() => _isChild = value ?? false),
                              activeColor: _textColor,
                              checkColor: _white,
                              side: BorderSide(
                                color: _textColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '아동용 계정인가요?',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              color: _textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 얼굴 정보 수집 동의 체크박스
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                              activeColor: _textColor,
                              checkColor: _white,
                              side: BorderSide(
                                color: _textColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '얼굴 정보 수집 및 이용에 동의합니다.',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                color: _textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // 다음 버튼
                      SizedBox(
                        width: 350, // 크기 축소
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _proceedToFaceRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _textColor,
                            foregroundColor: _white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '다음',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
