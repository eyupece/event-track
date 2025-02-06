import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event.dart';

// Event listesi için state notifier
class EventNotifier extends StateNotifier<List<Event>> {
  EventNotifier() : super([]); // Boş liste ile başlat

  // Yeni etkinlik ekleme
  void addEvent(Event event) {
    state = [...state, event];
  }

  // Etkinlik silme
  void deleteEvent(String id) {
    state = state.where((event) => event.id != id).toList();
  }

  // Etkinlik güncelleme
  void updateEvent(Event updatedEvent) {
    state = state
        .map((event) => event.id == updatedEvent.id ? updatedEvent : event)
        .toList();
  }

  // Tüm etkinlikleri getir
  List<Event> getAllEvents() {
    return state;
  }
}

// Global provider tanımı
final eventProvider = StateNotifierProvider<EventNotifier, List<Event>>((ref) {
  return EventNotifier();
});
