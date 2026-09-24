import 'package:flutter/material.dart';

enum CharacterMood { calm, happy, tired, worried, excited }

extension CharacterMoodPresentation on CharacterMood {
  String get label => switch (this) {
    CharacterMood.calm => '平静',
    CharacterMood.happy => '开心',
    CharacterMood.tired => '有些疲惫',
    CharacterMood.worried => '有点担心',
    CharacterMood.excited => '兴致很高',
  };

  IconData get icon => switch (this) {
    CharacterMood.calm => Icons.spa_outlined,
    CharacterMood.happy => Icons.wb_sunny_outlined,
    CharacterMood.tired => Icons.nights_stay_outlined,
    CharacterMood.worried => Icons.cloud_outlined,
    CharacterMood.excited => Icons.auto_awesome_rounded,
  };
}

class CharacterState {
  CharacterState({
    required this.mood,
    required int energy,
    required int affection,
    required this.currentOutfitId,
    required this.lastInteractionAt,
    required this.currentTopic,
  }) : energy = _boundedScore(energy),
       affection = _boundedScore(affection);

  factory CharacterState.initial({DateTime? now}) => CharacterState(
    mood: CharacterMood.calm,
    energy: 76,
    affection: 12,
    currentOutfitId: 'daily',
    lastInteractionAt: now,
    currentTopic: null,
  );

  factory CharacterState.fromJson(Map<String, Object?> json) {
    final moodName = json['mood'];
    final mood = CharacterMood.values.firstWhere(
      (value) => value.name == moodName,
      orElse: () => CharacterMood.calm,
    );
    final outfit = json['currentOutfitId'];
    final topic = json['currentTopic'];
    final interaction = json['lastInteractionAt'];

    return CharacterState(
      mood: mood,
      energy: _readScore(json['energy'], fallback: 76),
      affection: _readScore(json['affection'], fallback: 12),
      currentOutfitId: outfit is String && outfit.isNotEmpty ? outfit : 'daily',
      lastInteractionAt: interaction is String
          ? DateTime.tryParse(interaction)?.toLocal()
          : null,
      currentTopic: topic is String && topic.isNotEmpty ? topic : null,
    );
  }

  final CharacterMood mood;
  final int energy;
  final int affection;
  final String currentOutfitId;
  final DateTime? lastInteractionAt;
  final String? currentTopic;

  Map<String, Object?> toJson() => {
    'mood': mood.name,
    'energy': energy,
    'affection': affection,
    'currentOutfitId': currentOutfitId,
    'lastInteractionAt': lastInteractionAt?.toUtc().toIso8601String(),
    'currentTopic': currentTopic,
  };

  CharacterState afterUserMessage(String message, {DateTime? at}) {
    final normalized = message.toLowerCase();
    final nextMood =
        normalized.contains('累') ||
            normalized.contains('困') ||
            normalized.contains('疲惫')
        ? CharacterMood.tired
        : normalized.contains('担心') ||
              normalized.contains('焦虑') ||
              normalized.contains('害怕') ||
              normalized.contains('难过') ||
              normalized.contains('烦')
        ? CharacterMood.worried
        : normalized.contains('期待') ||
              normalized.contains('激动') ||
              normalized.contains('太好了')
        ? CharacterMood.excited
        : normalized.contains('开心') ||
              normalized.contains('高兴') ||
              normalized.contains('喜欢')
        ? CharacterMood.happy
        : CharacterMood.calm;
    final topic = message.trim().runes.take(24).map(String.fromCharCode).join();

    return CharacterState(
      mood: nextMood,
      energy: energy - 2,
      affection: affection + 1,
      currentOutfitId: currentOutfitId,
      lastInteractionAt: at ?? DateTime.now(),
      currentTopic: topic.isEmpty ? currentTopic : topic,
    );
  }

  CharacterState withOutfit(String outfitId) => CharacterState(
    mood: mood,
    energy: energy,
    affection: affection,
    currentOutfitId: outfitId,
    lastInteractionAt: lastInteractionAt,
    currentTopic: currentTopic,
  );

  static int _readScore(Object? value, {required int fallback}) {
    if (value is int) return _boundedScore(value);
    return fallback;
  }

  static int _boundedScore(int value) => value.clamp(0, 100);
}
