class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final String imageUrl;
  final String creatorName;
  final DateTime eventDate;
  final DateTime createdAt;
  final List<String> participants;
  final List<String> reports;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.creatorName,
    required this.eventDate,
    required this.createdAt,
    required this.participants,
    required this.reports,
  });

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      creatorName: map['creatorName'] ?? 'Anonim',
      eventDate:
          DateTime.parse(map['eventDate'] ?? DateTime.now().toIso8601String()),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      participants: List<String>.from(map['participants'] ?? []),
      reports: List<String>.from(map['reports'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'creatorName': creatorName,
      'eventDate': eventDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'participants': participants,
      'reports': reports,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? imageUrl,
    String? creatorName,
    DateTime? eventDate,
    DateTime? createdAt,
    List<String>? participants,
    List<String>? reports,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorName: creatorName ?? this.creatorName,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
      reports: reports ?? this.reports,
    );
  }
}
