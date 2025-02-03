import 'package:flutter/material.dart';
import '../../domain/models/event_model.dart';

abstract class IEventRepository {
  Future<List<Event>> getEvents();
  Future<Event?> getEventById(String id);
  Future<void> addEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
  Future<List<Event>> getEventsByCategory(String category);
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end);
}

class EventRepository implements IEventRepository {
  final List<Event> _events = [];

  @override
  Future<List<Event>> getEvents() async {
    return List.from(_events);
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addEvent(Event event) async {
    _events.add(event);
    _sortEvents();
  }

  @override
  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      _sortEvents();
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
  }

  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    return _events.where((event) => event.category == category).toList();
  }

  @override
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    return _events.where((event) {
      return event.date.isAfter(start.subtract(const Duration(days: 1))) &&
          event.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  void _sortEvents() {
    _events.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;

      return TimeOfDay(hour: a.time.hour, minute: a.time.minute)
          .hour
          .compareTo(TimeOfDay(hour: b.time.hour, minute: b.time.minute).hour);
    });
  }

  int getEventCountByCategory(String category) {
    return _events.where((event) => event.category == category).length;
  }

  Map<String, int> getCategoryStatistics() {
    final stats = <String, int>{};
    for (final event in _events) {
      stats[event.category] = (stats[event.category] ?? 0) + 1;
    }
    return stats;
  }
}
