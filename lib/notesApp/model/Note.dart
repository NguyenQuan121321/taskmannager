class Note {
  final int? id;
  final String title;
  final String content;
  final int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String>? tags;
  final String? color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  }) {
    if (priority < 1 || priority > 3) {
      throw ArgumentError('Priority must be between 1 and 3, but got $priority');
    }
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    try {
      List<String>? tags;
      if (map['tags'] != null && map['tags'].toString().trim().isNotEmpty) {
        tags = map['tags'].toString().split(',').map((tag) => tag.trim()).toList();
      }

      return Note(
        id: map['id'] as int?,
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        priority: map['priority'] as int? ?? 1,
        createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
        modifiedAt: DateTime.parse(map['modifiedAt'] as String? ?? DateTime.now().toIso8601String()),
        tags: tags,
        color: map['color'] as String?,
      );
    } catch (e) {
      throw FormatException('Error parsing Note from map: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags?.join(','),
      'color': color,
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, priority: $priority, createdAt: $createdAt, modifiedAt: $modifiedAt)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Note &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              content == other.content &&
              priority == other.priority &&
              createdAt == other.createdAt &&
              modifiedAt == other.modifiedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      priority.hashCode ^
      createdAt.hashCode ^
      modifiedAt.hashCode;
}