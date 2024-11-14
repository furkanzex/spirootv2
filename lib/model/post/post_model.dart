class Post {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String content;
  final String? image;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final List<String> tags;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.content,
    this.image,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.tags,
  });
}
