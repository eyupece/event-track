import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String category;
  final String? location;
  final List<String>? photos;
  final String? notes;
  final bool isCompleted;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.category,
    this.location,
    this.photos,
    this.notes,
    this.isCompleted = false,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    String? category,
    String? location,
    List<String>? photos,
    String? notes,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      location: location ?? this.location,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'category': category,
      'location': location,
      'photos': photos,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    final timeStr = json['time'] as String;
    final timeParts = timeStr.split(':');

    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      category: json['category'] as String,
      location: json['location'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>(),
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
