class Comment {
  final String id;
  final String content;
  final String creatorName;
  final DateTime createdAt;
  final List<String> reports;

  Comment({
    required this.id,
    required this.content,
    required this.creatorName,
    required this.createdAt,
    required this.reports,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      content: map['content'] ?? '',
      creatorName: map['creatorName'] ?? 'Anonim',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      reports: List<String>.from(map['reports'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'reports': reports,
    };
  }

  Comment copyWith({
    String? id,
    String? content,
    String? creatorName,
    DateTime? createdAt,
    List<String>? reports,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      reports: reports ?? this.reports,
    );
  }
}
