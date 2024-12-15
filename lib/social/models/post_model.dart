class Post {
  final String id;
  final String content;
  final String creatorName;
  final DateTime createdAt;
  final List<String> likes;
  final int commentCount;
  final List<String> reports;
  final bool isExpanded;

  Post({
    required this.id,
    required this.content,
    required this.creatorName,
    required this.createdAt,
    required this.likes,
    required this.commentCount,
    required this.reports,
    this.isExpanded = false,
  });

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      content: map['content'] ?? '',
      creatorName: map['creatorName'] ?? 'Anonim',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      reports: List<String>.from(map['reports'] ?? []),
      isExpanded: map['isExpanded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'commentCount': commentCount,
      'reports': reports,
      'isExpanded': isExpanded,
    };
  }

  Post copyWith({
    String? id,
    String? content,
    String? creatorName,
    DateTime? createdAt,
    List<String>? likes,
    int? commentCount,
    List<String>? reports,
    bool? isExpanded,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      reports: reports ?? this.reports,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
