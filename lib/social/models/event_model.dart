class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final String imageUrl;
  final String creatorName;
  final String creatorId;
  final DateTime eventDate;
  final DateTime createdAt;
  final List<String> participants;
  final List<String> reports;
  final int commentCount;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.creatorName,
    required this.creatorId,
    required this.eventDate,
    required this.createdAt,
    required this.participants,
    required this.reports,
    this.commentCount = 0,
  });

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      creatorName: map['creatorName'] ?? 'Anonim',
      creatorId: map['creatorId'] ?? '',
      eventDate:
          DateTime.parse(map['eventDate'] ?? DateTime.now().toIso8601String()),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      participants: List<String>.from(map['participants'] ?? []),
      reports: List<String>.from(map['reports'] ?? []),
      commentCount: map['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'creatorName': creatorName,
      'creatorId': creatorId,
      'eventDate': eventDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'participants': participants,
      'reports': reports,
      'commentCount': commentCount,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? imageUrl,
    String? creatorName,
    String? creatorId,
    DateTime? eventDate,
    DateTime? createdAt,
    List<String>? participants,
    List<String>? reports,
    int? commentCount,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorName: creatorName ?? this.creatorName,
      creatorId: creatorId ?? this.creatorId,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
      reports: reports ?? this.reports,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
