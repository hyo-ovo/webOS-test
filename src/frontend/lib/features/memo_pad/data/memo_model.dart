enum MemoSlotType { topLeft, topRight, bottomLeft, bottomRight }

extension MemoSlotTypeX on MemoSlotType {
  int get apiValue {
    switch (this) {
      case MemoSlotType.topLeft:
        return 1;
      case MemoSlotType.topRight:
        return 2;
      case MemoSlotType.bottomLeft:
        return 3;
      case MemoSlotType.bottomRight:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case MemoSlotType.topLeft:
        return '왼쪽 위';
      case MemoSlotType.topRight:
        return '오른쪽 위';
      case MemoSlotType.bottomLeft:
        return '왼쪽 아래';
      case MemoSlotType.bottomRight:
        return '오른쪽 아래';
    }
  }

  static MemoSlotType fromApiValue(dynamic value) {
    if (value is int) {
      return MemoSlotType.values.firstWhere(
        (type) => type.apiValue == value,
        orElse: () {
          return MemoSlotType.topLeft;
        },
      );
    }

    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return fromApiValue(parsed);
      }
    }

    return MemoSlotType.topLeft;
  }

  static String runId(MemoSlotType type) => 'memo-slot-${type.apiValue}';
}

class Memo {
  const Memo({
    required this.id,
    required this.type,
    required this.text,
    required this.runPatasdh,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final MemoSlotType type;
  final String text;
  final String runPatasdh;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Memo copyWith({
    String? id,
    MemoSlotType? type,
    String? text,
    String? runPatasdh,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memo(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      runPatasdh: runPatasdh ?? this.runPatasdh,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'text': text,
      'memoType': type.apiValue,
      'runPatasdh': runPatasdh,
    };
  }

  static Memo fromJson(Map<String, dynamic> json) {
    final dynamic typeValue = json['memoType'] ?? json['type'];
    final memoType = MemoSlotTypeX.fromApiValue(typeValue);

    return Memo(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: memoType,
      text: (json['text'] ?? '').toString(),
      runPatasdh:
          (json['runPatasdh'] ?? MemoSlotTypeX.runId(memoType)).toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    if (value is int) {
      // assume milliseconds
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }
}
