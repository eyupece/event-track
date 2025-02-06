import 'package:flutter/material.dart';
import 'package:event_track/features/events/domain/models/category.dart';

class CategoryConstants {
  static final List<Category> defaultCategories = [
    Category(
      id: 'concert',
      name: 'Konser',
      icon: Icons.music_note,
      color: Colors.purple,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'technology',
      name: 'Teknoloji',
      icon: Icons.computer,
      color: Colors.blue,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'cinema',
      name: 'Sinema',
      icon: Icons.movie,
      color: Colors.red,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'theatre',
      name: 'Tiyatro',
      icon: Icons.theater_comedy,
      color: Colors.orange,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'sports',
      name: 'Spor',
      icon: Icons.sports_soccer,
      color: Colors.green,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
  ];

  static Category getCategoryById(String id) {
    return defaultCategories.firstWhere(
      (category) => category.id == id,
      orElse: () => defaultCategories.first,
    );
  }

  static Category getCategoryByName(String name) {
    return defaultCategories.firstWhere(
      (category) => category.name == name,
      orElse: () => defaultCategories.first,
    );
  }
}
