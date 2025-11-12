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

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _proceedToFaceRegistration() {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('얼굴 정보 수집에 동의해주세요'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FaceLoginWidget(
          isRegistration: true,
          username: _usernameController.text.trim(),
          isChild: _isChild,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                
                const Text(
                  '회원가입',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '기본 정보를 입력해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 50),
                
                // 사용자 이름 입력
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: '사용자 이름',
                    labelStyle: const TextStyle(fontSize: 16),
                    hintText: '이름을 입력하세요',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    if (value.trim().length < 2) {
                      return '이름은 2자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                // 아동용 계정 선택
                Row(
                  children: [
                    Checkbox(
                      value: _isChild,
                      onChanged: (value) => setState(() => _isChild = value ?? false),
                      activeColor: const Color(0xFF4A90E2),
                    ),
                    const Expanded(
                      child: Text(
                        '아동용 계정입니다',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // 개인정보 동의
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      activeColor: const Color(0xFF4A90E2),
                    ),
                    const Expanded(
                      child: Text(
                        '얼굴 정보 수집 및 이용에 동의합니다',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // 다음 버튼
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _proceedToFaceRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
