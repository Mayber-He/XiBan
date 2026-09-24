import 'dart:convert';

enum MemoryCategory {
  preference('偏好'),
  importantDate('重要日期'),
  routine('生活习惯'),
  relationship('关系设定'),
  temporary('临时上下文');

  const MemoryCategory(this.label);

  final String label;
}

class CompanionMemory {
  CompanionMemory({
    required this.id,
    required this.userId,
    required this.content,
    required this.category,
    required int importance,
    required this.sourceMessageId,
    required this.createdAt,
    required this.updatedAt,
    required this.isEnabled,
  }) : importance = importance.clamp(1, 5);

  factory CompanionMemory.fromJson(Map<String, Object?> json) {
    final categoryName = json['category'];
    final category = MemoryCategory.values.firstWhere(
      (value) => value.name == categoryName,
      orElse: () => MemoryCategory.routine,
    );
    final now = DateTime.now();
    final createdAt = _readDate(json['createdAt']) ?? now;
    final updatedAt = _readDate(json['updatedAt']) ?? createdAt;
    final sourceId = json['sourceMessageId'];

    return CompanionMemory(
      id: json['id'] is String ? json['id']! as String : '',
      userId: json['userId'] is String
          ? json['userId']! as String
          : 'local-user',
      content: json['content'] is String ? json['content']! as String : '',
      category: category,
      importance: json['importance'] is int ? json['importance']! as int : 3,
      sourceMessageId: sourceId is String ? sourceId : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEnabled: json['isEnabled'] is bool ? json['isEnabled']! as bool : true,
    );
  }

  final String id;
  final String userId;
  final String content;
  final MemoryCategory category;
  final int importance;
  final String? sourceMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEnabled;

  CompanionMemory copyWith({
    String? content,
    MemoryCategory? category,
    int? importance,
    String? sourceMessageId,
    DateTime? updatedAt,
    bool? isEnabled,
  }) => CompanionMemory(
    id: id,
    userId: userId,
    content: content ?? this.content,
    category: category ?? this.category,
    importance: importance ?? this.importance,
    sourceMessageId: sourceMessageId ?? this.sourceMessageId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isEnabled: isEnabled ?? this.isEnabled,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'userId': userId,
    'content': content,
    'category': category.name,
    'importance': importance,
    'sourceMessageId': sourceMessageId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'isEnabled': isEnabled,
  };

  String encode() => jsonEncode(toJson());

  static DateTime? _readDate(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}
