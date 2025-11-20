import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/luna_keyboard_service.dart';
import '../../data/memo_model.dart';
import '../../logic/controllers/memo_controller.dart';

class MemoBoardWidget extends StatefulWidget {
  const MemoBoardWidget({super.key});

  @override
  State<MemoBoardWidget> createState() => _MemoBoardWidgetState();
}

class _MemoBoardWidgetState extends State<MemoBoardWidget> {
  late final MemoController _controller;
  final LunaKeyboardService _keyboardService = LunaKeyboardService();

  @override
  void initState() {
    super.initState();
    _controller = MemoController();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadInitial();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<MemoController>(
        builder: (context, controller, _) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 28,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MemoHeader(
                  isLoading: controller.isLoading,
                  onRefresh: controller.isLoading ? null : controller.refresh,
                  onCreate: controller.hasEmptySlot
                      ? () => _openMemoEditorForFirstEmpty(controller)
                      : null,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _MemoGrid(
                          controller: controller,
                          onTileTap: (slotType, memo) =>
                              _openMemoEditor(slotType, memo),
                        ),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 18),
                  _ErrorBanner(message: controller.errorMessage!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMemoEditorForFirstEmpty(MemoController controller) {
    final slots = controller.slots;
    for (var i = 0; i < slots.length; i++) {
      if (slots[i] == null) {
        _openMemoEditor(controller.slotTypeAt(i), null);
        return;
      }
    }
    // 모든 슬롯이 차있으면 첫 번째 슬롯 수정으로 fallback
    _openMemoEditor(MemoSlotType.topLeft, controller.slots.first);
  }

  Future<void> _openMemoEditor(MemoSlotType slot, Memo? memo) async {
    final result = await showDialog<_MemoEditorResult>(
      context: context,
      builder: (context) => _MemoEditorDialog(
        memo: memo,
        slotType: slot,
        keyboardService: _keyboardService,
      ),
    );

    if (!mounted || result == null) return;

    if (result.action == _MemoEditorAction.delete) {
      final deleted = await _controller.deleteMemo(slot);
      if (deleted && mounted) {
        _showSnack('메모를 삭제했어요.');
      }
      return;
    }

    if (result.text == null) return;

    final saved = await _controller.saveMemo(
      slotType: slot,
      text: result.text!,
    );

    if (saved && mounted) {
      _showSnack('메모를 저장했어요.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MemoHeader extends StatelessWidget {
  const _MemoHeader({
    required this.isLoading,
    required this.onRefresh,
    required this.onCreate,
  });

  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '메모하기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1F25),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.edit_note_rounded, color: Color(0xFF9AA0AF)),
        const Spacer(),
        IconButton(
          tooltip: '새로고침',
          onPressed: onRefresh == null ? null : () => onRefresh!(),
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.note_add_rounded),
          label: const Text('메모 생성'),
        ),
      ],
    );
  }
}

class _MemoGrid extends StatelessWidget {
  const _MemoGrid({required this.controller, required this.onTileTap});

  final MemoController controller;
  final void Function(MemoSlotType slotType, Memo? memo) onTileTap;

  static const Map<MemoSlotType, Color> _colors = {
    MemoSlotType.topLeft: Color(0xFF6DE4A5),
    MemoSlotType.topRight: Color(0xFFFFE28B),
    MemoSlotType.bottomLeft: Color(0xFF8AD3FF),
    MemoSlotType.bottomRight: Color(0xFFFFB6C1),
  };

  @override
  Widget build(BuildContext context) {
    final slots = controller.slots;
    return Stack(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
          ),
          itemBuilder: (context, index) {
            final slotType = controller.slotTypeAt(index);
            final memo = slots[index];
            return _MemoSlotTile(
              color: _colors[slotType] ?? Colors.grey.shade200,
              memo: memo,
              slotType: slotType,
              onTap: () => onTileTap(slotType, memo),
            );
          },
        ),
        if (controller.isMutating)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _MemoSlotTile extends StatelessWidget {
  const _MemoSlotTile({
    required this.color,
    required this.slotType,
    this.memo,
    required this.onTap,
  });

  final Color color;
  final MemoSlotType slotType;
  final Memo? memo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 18,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memo?.runPatasdh.toUpperCase() ??
                    'SLOT ${slotType.apiValue.toString()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF272B33),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: memo == null
                    ? _EmptyMemoBody(slotType: slotType)
                    : Text(
                        memo!.text,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF3B3F46),
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMemoBody extends StatelessWidget {
  const _EmptyMemoBody({required this.slotType});

  final MemoSlotType slotType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${slotType.label} 메모',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3B3F46),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Icon(Icons.add_box_outlined),
            SizedBox(width: 8),
            Text('메모 생성'),
          ],
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

enum _MemoEditorAction { save, delete }

class _MemoEditorResult {
  const _MemoEditorResult._(this.action, {this.text});

  final _MemoEditorAction action;
  final String? text;

  factory _MemoEditorResult.save({required String text}) {
    return _MemoEditorResult._(_MemoEditorAction.save, text: text);
  }

  factory _MemoEditorResult.delete() {
    return const _MemoEditorResult._(_MemoEditorAction.delete);
  }
}

class _MemoEditorDialog extends StatefulWidget {
  const _MemoEditorDialog({
    required this.slotType,
    required this.keyboardService,
    this.memo,
  });

  final Memo? memo;
  final MemoSlotType slotType;
  final LunaKeyboardService keyboardService;

  @override
  State<_MemoEditorDialog> createState() => _MemoEditorDialogState();
}

class _MemoEditorDialogState extends State<_MemoEditorDialog> {
  late final TextEditingController _textController;
  final FocusNode _textFocusNode = FocusNode();

  String get _runPatasdh =>
      widget.memo?.runPatasdh ?? MemoSlotTypeX.runId(widget.slotType);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.memo?.text ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
      widget.keyboardService.showKeyboard(
        runPatasdh: _runPatasdh,
        initialText: _textController.text,
      );
    });

    _textFocusNode.addListener(() {
      if (_textFocusNode.hasFocus) {
        widget.keyboardService.showKeyboard(
          runPatasdh: _runPatasdh,
          initialText: _textController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    widget.keyboardService.hideKeyboard(runPatasdh: _runPatasdh);
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.memo == null ? '새 메모' : '메모 수정'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              maxLength: 400,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: '${widget.slotType.label} 메모 내용',
                alignLabelWithHint: true,
                hintText: '메모 내용을 입력해 주세요.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.memo != null)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_MemoEditorResult.delete()),
            child: const Text('삭제'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _MemoEditorResult.save(
              text: _textController.text,
            ),
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}
