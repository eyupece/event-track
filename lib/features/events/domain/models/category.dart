import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // JSON deserialization
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // CopyWith method for immutability
  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
