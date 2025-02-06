class Event {
  final String id;
  final String title;
  final DateTime date;
  final String category;
  final String? location;
  final String? description;
  final List<String> photoUrls;
  final List<String> notes;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    this.location,
    this.description,
    this.photoUrls = const [],
    this.notes = const [],
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'category': category,
      'location': location,
      'description': description,
      'photoUrls': photoUrls,
      'notes': notes,
    };
  }

  // JSON deserialization
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
    );
  }

  // CopyWith method for immutability
  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? category,
    String? location,
    String? description,
    List<String>? photoUrls,
    List<String>? notes,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      notes: notes ?? this.notes,
    );
  }
}
