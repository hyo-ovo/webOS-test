import 'memo_api.dart';
import 'models/memo.dart';

class MemoRepository {
  MemoRepository({MemoApi? api}) : _api = api ?? MemoApi();

  final MemoApi _api;

  Future<List<Memo>> fetchMemos() => _api.fetchMemos();

  Future<Memo> saveMemo({
    required int memoType,
    required String content,
    String? memoId,
  }) async {
    if (memoId == null || memoId.isEmpty) {
      return _api.createMemo(memoType: memoType, content: content);
    }
    return _api.updateMemo(id: memoId, content: content);
  }

  Future<void> deleteMemo(String memoId) => _api.deleteMemo(memoId);
}


