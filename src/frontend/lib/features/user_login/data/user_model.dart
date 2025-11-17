class UserModel {
  final int id;
  final String username;
  final String? token;
  final bool isChild;
  final String? characterImagePath; // 선택한 빈버드 캐릭터 이미지 경로

  UserModel({
    required this.id,
    required this.username,
    this.token,
    this.isChild = false,
    this.characterImagePath,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      token: json['token'] as String?,
      isChild: json['isChild'] as bool? ?? false,
      characterImagePath: json['characterImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
      'isChild': isChild,
      'characterImagePath': characterImagePath,
    };
  }
}
