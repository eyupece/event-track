import '../../domain/models/event.dart';

abstract class IEventRepository {
  Future<List<Event>> getEvents();
  Future<Event?> getEventById(String id);
  Future<void> addEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String id);
  Future<List<Event>> getEventsByCategory(String category);
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end);
}

// Local storage implementation (Hive)
class LocalEventRepository implements IEventRepository {
  @override
  Future<List<Event>> getEvents() async {
    // TODO: Implement local storage
    return [];
  }

  @override
  Future<Event?> getEventById(String id) async {
    // TODO: Implement local storage
    return null;
  }

  @override
  Future<void> addEvent(Event event) async {
    // TODO: Implement local storage
  }

  @override
  Future<void> updateEvent(Event event) async {
    // TODO: Implement local storage
  }

  @override
  Future<void> deleteEvent(String id) async {
    // TODO: Implement local storage
  }

  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    // TODO: Implement local storage
    return [];
  }

  @override
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    // TODO: Implement local storage
    return [];
  }
}
