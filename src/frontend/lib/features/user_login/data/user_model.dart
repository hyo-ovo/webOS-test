class UserModel {
  final int id;
  final String username;
  final String? token;
  final bool isChild;

  UserModel({
    required this.id,
    required this.username,
    this.token,
    this.isChild = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      token: json['token'] as String?,
      isChild: json['isChild'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
      'isChild': isChild,
    };
  }
}
