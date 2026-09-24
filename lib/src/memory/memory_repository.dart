import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'companion_memory.dart';

abstract interface class MemoryRepository {
  Future<List<CompanionMemory>> loadMemories();
  Future<void> saveMemories(List<CompanionMemory> memories);
  Future<bool> loadEnabled();
  Future<void> saveEnabled(bool enabled);
}

class SharedPreferencesMemoryRepository implements MemoryRepository {
  SharedPreferencesMemoryRepository({this.preferences});

  static const _memoriesKey = 'companion_memories_v1';
  static const _enabledKey = 'companion_memories_enabled_v1';

  final SharedPreferences? preferences;

  Future<SharedPreferences> get _store async =>
      preferences ?? SharedPreferences.getInstance();

  @override
  Future<List<CompanionMemory>> loadMemories() async {
    final raw = (await _store).getString(_memoriesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final values = jsonDecode(raw);
      if (values is! List) return [];
      return values
          .whereType<Map<String, dynamic>>()
          .map(CompanionMemory.fromJson)
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> saveMemories(List<CompanionMemory> memories) async {
    final encoded = jsonEncode(
      memories.map((memory) => memory.toJson()).toList(),
    );
    await (await _store).setString(_memoriesKey, encoded);
  }

  @override
  Future<bool> loadEnabled() async =>
      (await _store).getBool(_enabledKey) ?? false;

  @override
  Future<void> saveEnabled(bool enabled) async {
    await (await _store).setBool(_enabledKey, enabled);
  }
}

class InMemoryMemoryRepository implements MemoryRepository {
  InMemoryMemoryRepository({List<CompanionMemory> initial = const []})
    : _memories = List.of(initial);

  List<CompanionMemory> _memories;
  bool _enabled = false;

  @override
  Future<List<CompanionMemory>> loadMemories() async => List.of(_memories);

  @override
  Future<void> saveMemories(List<CompanionMemory> memories) async {
    _memories = List.of(memories);
  }

  @override
  Future<bool> loadEnabled() async => _enabled;

  @override
  Future<void> saveEnabled(bool enabled) async {
    _enabled = enabled;
  }
}
