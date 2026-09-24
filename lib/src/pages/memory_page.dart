import 'package:flutter/material.dart';

import '../memory/companion_memory.dart';
import '../memory/memory_controller.dart';
import '../theme/app_theme.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key, required this.controller});

  final MemoryController controller;

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  Future<void> _edit([CompanionMemory? memory]) async {
    final draft = await showDialog<_MemoryDraft>(
      context: context,
      builder: (_) => _MemoryEditorDialog(memory: memory),
    );
    if (draft == null || !mounted) return;
    if (memory == null) {
      await widget.controller.add(
        content: draft.content,
        category: draft.category,
        importance: draft.importance,
      );
    } else {
      await widget.controller.update(
        memory.id,
        content: draft.content,
        category: draft.category,
        importance: draft.importance,
      );
    }
    if (mounted && widget.controller.hasError) _showSaveError();
  }

  Future<void> _delete(CompanionMemory memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这条记忆？'),
        content: const Text('删除后，这条内容会从本机记录中移除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.controller.delete(memory.id);
    if (mounted && widget.controller.hasError) _showSaveError();
  }

  void _showSaveError() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('暂时无法保存，请稍后重试。')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '记忆管理',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '由你决定她可以记住什么。',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      key: const Key('add-memory-button'),
                      onPressed: () => _edit(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('添加记忆'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    if (widget.controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                      children: [
                        _PrivacyCard(
                          enabled: widget.controller.isEnabled,
                          onChanged: (value) async {
                            await widget.controller.setEnabled(value);
                            if (mounted && widget.controller.hasError) {
                              _showSaveError();
                            }
                          },
                        ),
                        if (widget.controller.hasError) ...[
                          const SizedBox(height: 12),
                          const _InlineError(),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '你保存的记忆',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Text(
                              '${widget.controller.memories.length} 条',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (widget.controller.memories.isEmpty)
                          const _EmptyMemoryCard()
                        else
                          for (final memory in widget.controller.memories)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MemoryCard(
                                memory: memory,
                                onEdit: () => _edit(memory),
                                onDelete: () => _delete(memory),
                                onEnabledChanged: (value) async {
                                  await widget.controller.setMemoryEnabled(
                                    memory.id,
                                    value,
                                  );
                                  if (mounted && widget.controller.hasError) {
                                    _showSaveError();
                                  }
                                },
                              ),
                            ),
                        const SizedBox(height: 12),
                        Text(
                          '记忆保存在此设备。当前聊天演示不会读取这些内容；云端同步尚未配置。',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF2ED),
      child: SwitchListTile.adaptive(
        key: const Key('memory-global-switch'),
        value: enabled,
        onChanged: onChanged,
        activeTrackColor: AppTheme.coral,
        secondary: const Icon(Icons.shield_outlined, color: AppTheme.coral),
        title: const Text('长期记忆总开关'),
        subtitle: const Text('默认关闭。开启后，未来接入的聊天服务才可参考已启用的记忆。'),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppTheme.coral),
            SizedBox(width: 10),
            Expanded(child: Text('保存失败，请检查设备存储后重试。')),
          ],
        ),
      ),
    );
  }
}

class _EmptyMemoryCard extends StatelessWidget {
  const _EmptyMemoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.bookmark_border_rounded,
              size: 34,
              color: AppTheme.coral,
            ),
            const SizedBox(height: 12),
            Text('还没有保存的记忆', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              '你可以手动添加希望保留的偏好或重要事项。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.memory,
    required this.onEdit,
    required this.onDelete,
    required this.onEnabledChanged,
  });

  final CompanionMemory memory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final textColor = memory.isEnabled ? AppTheme.ink : AppTheme.mutedInk;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    memory.content,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: textColor),
                  ),
                ),
                IconButton(
                  tooltip: '编辑记忆',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: '删除记忆',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(memory.category.label),
                  side: BorderSide.none,
                  backgroundColor: AppTheme.blush,
                ),
                Text(
                  '重要程度 ${memory.importance}/5',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '更新于 ${memory.updatedAt.month}月${memory.updatedAt.day}日',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    memory.isEnabled ? '参与记忆' : '已暂停',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 6),
                  Switch.adaptive(
                    key: Key('memory-toggle-${memory.id}'),
                    value: memory.isEnabled,
                    onChanged: onEnabledChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryDraft {
  const _MemoryDraft(this.content, this.category, this.importance);

  final String content;
  final MemoryCategory category;
  final int importance;
}

class _MemoryEditorDialog extends StatefulWidget {
  const _MemoryEditorDialog({this.memory});

  final CompanionMemory? memory;

  @override
  State<_MemoryEditorDialog> createState() => _MemoryEditorDialogState();
}

class _MemoryEditorDialogState extends State<_MemoryEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _contentController = TextEditingController(
    text: widget.memory?.content ?? '',
  );
  late MemoryCategory _category =
      widget.memory?.category ?? MemoryCategory.preference;
  late int _importance = widget.memory?.importance ?? 3;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _MemoryDraft(_contentController.text.trim(), _category, _importance),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.memory == null ? '添加一条记忆' : '编辑记忆'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('记忆内容'),
                const SizedBox(height: 6),
                TextFormField(
                  key: const Key('memory-content'),
                  controller: _contentController,
                  maxLines: 4,
                  maxLength: 500,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: '例如：我喜欢周末早上去散步',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '请先填写记忆内容' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MemoryCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: '分类',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final value in MemoryCategory.values)
                      DropdownMenuItem(value: value, child: Text(value.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _importance,
                  decoration: const InputDecoration(
                    labelText: '重要程度',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var score = 1; score <= 5; score++)
                      DropdownMenuItem(value: score, child: Text('$score / 5')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _importance = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}
