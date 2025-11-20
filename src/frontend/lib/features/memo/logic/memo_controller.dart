import 'package:flutter/foundation.dart';

import '../data/memo_repository.dart';
import '../data/models/memo.dart';

class MemoController extends ChangeNotifier {
  MemoController({MemoRepository? repository})
      : _repository = repository ?? MemoRepository() {
    _slots = List<Memo?>.filled(4, null);
  }

  final MemoRepository _repository;

  late List<Memo?> _slots;
  bool _isLoading = false;
  String? _error;

  List<Memo?> get memoSlots => List.unmodifiable(_slots);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMemos() async {
    _setLoading(true);
    try {
      final memos = await _repository.fetchMemos();
      _slots = List<Memo?>.filled(4, null);
      for (final memo in memos) {
        final idx = memo.memoType - 1;
        if (idx >= 0 && idx < _slots.length) {
          _slots[idx] = memo;
        }
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '메모를 불러오지 못했습니다: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveMemo({
    required int memoType,
    required String content,
  }) async {
    _setLoading(true);
    try {
      final existing = _slots[memoType - 1];
      final saved = await _repository.saveMemo(
        memoType: memoType,
        content: content,
        memoId: existing?.id,
      );
      _slots[memoType - 1] = saved;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '메모 저장 실패: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMemo(int memoType) async {
    final target = _slots[memoType - 1];
    if (target == null) return;

    _setLoading(true);
    try {
      await _repository.deleteMemo(target.id);
      _slots[memoType - 1] = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '메모 삭제 실패: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}


