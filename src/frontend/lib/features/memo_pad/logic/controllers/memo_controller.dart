import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../data/memo_api_service.dart';
import '../../data/memo_model.dart';

class MemoController extends ChangeNotifier {
  MemoController({MemoApiService? apiService})
      : _apiService = apiService ?? MemoApiService();

  final MemoApiService _apiService;

  static const List<MemoSlotType> _slotOrder = [
    MemoSlotType.topLeft,
    MemoSlotType.topRight,
    MemoSlotType.bottomLeft,
    MemoSlotType.bottomRight,
  ];

  final Map<MemoSlotType, Memo?> _memoByType = {
    for (final slot in _slotOrder) slot: null,
  };

  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;

  UnmodifiableListView<Memo?> get slots =>
      UnmodifiableListView(_slotOrder.map((slot) => _memoByType[slot]));

  bool get hasEmptySlot => _memoByType.values.any((memo) => memo == null);

  MemoSlotType slotTypeAt(int index) => _slotOrder[index];

  Future<void> loadInitial() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      final memos = await _apiService.fetchMemos();
      for (final slot in _slotOrder) {
        _memoByType[slot] = null;
      }
      for (final memo in memos) {
        _memoByType[memo.type] = memo;
      }
      _errorMessage = null;
    } catch (error) {
      debugPrint('[MemoController] loadInitial error: $error');
      _errorMessage = '메모를 불러오지 못했어요.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadInitial();

  Future<bool> saveMemo({
    required MemoSlotType slotType,
    required String text,
  }) async {
    if (_isMutating) return false;
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _errorMessage = '메모 내용을 입력해 주세요.';
      notifyListeners();
      return false;
    }

    _setMutating(true);
    try {
      final existing = _memoByType[slotType];
      Memo result;
      if (existing == null) {
        result = await _apiService.createMemo(
          memoType: slotType,
          text: trimmed,
          runPatasdh: MemoSlotTypeX.runId(slotType),
        );
      } else {
        result = await _apiService.updateMemo(
          existing.copyWith(text: trimmed),
        );
      }
      _memoByType[slotType] = result;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('[MemoController] saveMemo error: $error');
      _errorMessage = '메모를 저장하는 중 오류가 발생했어요.';
      notifyListeners();
      return false;
    } finally {
      _setMutating(false);
    }
  }

  Future<bool> deleteMemo(MemoSlotType slotType) async {
    final existing = _memoByType[slotType];
    if (existing == null || _isMutating) return false;

    _setMutating(true);
    try {
      await _apiService.deleteMemo(existing.id);
      _memoByType[slotType] = null;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('[MemoController] deleteMemo error: $error');
      _errorMessage = '메모 삭제에 실패했어요.';
      notifyListeners();
      return false;
    } finally {
      _setMutating(false);
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMutating(bool value) {
    _isMutating = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
