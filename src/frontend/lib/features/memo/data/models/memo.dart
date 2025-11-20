class Memo {
  const Memo({
    required this.id,
    required this.memoType,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int memoType;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id']?.toString() ?? '',
      memoType: json['memoType'] is int
          ? json['memoType'] as int
          : int.tryParse(json['memoType']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'memoType': memoType,
        'content': content,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}


