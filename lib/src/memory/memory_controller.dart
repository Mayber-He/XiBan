import 'package:flutter/foundation.dart';

import 'companion_memory.dart';
import 'memory_repository.dart';

class MemoryController extends ChangeNotifier {
  MemoryController({required this.repository});

  final MemoryRepository repository;
  List<CompanionMemory> _memories = [];
  bool _isEnabled = false;
  bool _isLoading = true;
  bool _hasError = false;
  int _nextId = 0;

  List<CompanionMemory> get memories => List.unmodifiable(_memories);
  bool get isEnabled => _isEnabled;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> load() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final values = await Future.wait<Object>([
        repository.loadMemories(),
        repository.loadEnabled(),
      ]);
      _memories = values[0] as List<CompanionMemory>;
      _isEnabled = values[1] as bool;
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add({
    required String content,
    required MemoryCategory category,
    required int importance,
  }) async {
    final now = DateTime.now();
    _nextId++;
    final memory = CompanionMemory(
      id: '${now.microsecondsSinceEpoch}-$_nextId',
      userId: 'local-user',
      content: content.trim(),
      category: category,
      importance: importance,
      sourceMessageId: null,
      createdAt: now,
      updatedAt: now,
      isEnabled: true,
    );
    await _save([..._memories, memory]);
  }

  Future<void> update(
    String id, {
    required String content,
    required MemoryCategory category,
    required int importance,
  }) async {
    final now = DateTime.now();
    final next = _memories
        .map(
          (memory) => memory.id == id
              ? memory.copyWith(
                  content: content.trim(),
                  category: category,
                  importance: importance,
                  updatedAt: now,
                )
              : memory,
        )
        .toList();
    await _save(next);
  }

  Future<void> setMemoryEnabled(String id, bool enabled) async {
    final next = _memories
        .map(
          (memory) => memory.id == id
              ? memory.copyWith(isEnabled: enabled, updatedAt: DateTime.now())
              : memory,
        )
        .toList();
    await _save(next);
  }

  Future<void> delete(String id) async {
    await _save(_memories.where((memory) => memory.id != id).toList());
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await repository.saveEnabled(enabled);
      _isEnabled = enabled;
      _hasError = false;
    } catch (_) {
      _hasError = true;
    }
    notifyListeners();
  }

  Future<void> _save(List<CompanionMemory> next) async {
    try {
      await repository.saveMemories(next);
      _memories = next;
      _hasError = false;
    } catch (_) {
      _hasError = true;
    }
    notifyListeners();
  }
}
