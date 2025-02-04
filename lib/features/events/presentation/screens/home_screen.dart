import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import './add_event_screen.dart';
import '../../domain/models/event_model.dart';
import '../../data/repositories/event_repository.dart';
import '../widgets/event_list_item.dart';
import '../widgets/mini_calendar_widget.dart';

// Grafik çizimi için özel painter
class ChartPainter extends CustomPainter {
  final List<Color> colors;

  ChartPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      final points = _generatePoints(size, i);
      final path = Path();

      path.moveTo(points.first.dx, points.first.dy);

      for (var j = 1; j < points.length; j++) {
        final p0 = points[j - 1];
        final p1 = points[j];

        // Bezier eğrisi için kontrol noktaları
        final controlPoint1 = Offset(
          p0.dx + (p1.dx - p0.dx) / 2,
          p0.dy,
        );
        final controlPoint2 = Offset(
          p0.dx + (p1.dx - p0.dx) / 2,
          p1.dy,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  List<Offset> _generatePoints(Size size, int index) {
    final random = DateTime.now().millisecondsSinceEpoch + index;
    final points = <Offset>[];

    for (var i = 0; i < 5; i++) {
      points.add(
        Offset(
          i * size.width / 4,
          20 + (random + i * 1000) % (size.height - 40),
        ),
      );
    }

    return points;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late AnimationController _fabAnimationController;
  String? _selectedCategory;
  final String userName = "Eyüp"; // TODO: Gerçek kullanıcı adını al

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Konser',
      'icon': Icons.music_note,
      'color': const Color(0xFFFF6B6B),
      'count': 5,
    },
    {
      'name': 'Teknoloji',
      'icon': Icons.computer,
      'color': const Color(0xFFFFB84D),
      'count': 1,
    },
    {
      'name': 'Sinema',
      'icon': Icons.movie,
      'color': const Color(0xFF4ECDC4),
      'count': 2,
    },
  ];

  final EventRepository _eventRepository = EventRepository();
  List<Event> _events = [];
  Map<DateTime, List<Event>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _eventRepository.getEvents();
    final eventsByDay = <DateTime, List<Event>>{};

    for (var event in events) {
      final day = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (eventsByDay[day] == null) {
        eventsByDay[day] = [];
      }
      eventsByDay[day]!.add(event);
    }

    setState(() {
      _events = events;
      _eventsByDay = eventsByDay;
    });
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildSearchBar(),
            _buildMiniCalendar(),
            _buildCategoryGrid(),
            _buildEventsList(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Merhaba!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Etkinlik ara...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // TODO: Arama fonksiyonu
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.tune,
                  color: Colors.white70,
                ),
                onPressed: () {
                  // TODO: Filtre menüsü
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCalendar() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Filtrelenmiş etkinlikler
    final filteredEvents = _filteredEvents;

    // Tamamlanma durumuna göre hesaplama
    final completedEvents = filteredEvents.where((e) => e.isCompleted).length;
    final pendingEvents = filteredEvents.where((e) => !e.isCompleted).length;

    // Günlük etkinlikler (bugün)
    final dailyEvents = filteredEvents
        .where((e) =>
            e.date.isAfter(startOfDay.subtract(const Duration(days: 1))) &&
            e.date.isBefore(startOfDay.add(const Duration(days: 1))))
        .length;

    // Haftalık etkinlikler (bu hafta)
    final weeklyEvents = filteredEvents
        .where((e) =>
            e.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            e.date.isBefore(startOfWeek.add(const Duration(days: 7))))
        .length;

    // Aylık etkinlikler (bu ay)
    final monthlyEvents = filteredEvents
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .length;

    return SliverToBoxAdapter(
      child: MiniCalendarWidget(
        focusedDay: _focusedDay,
        selectedDay: _selectedDay,
        onDaySelected: _onDaySelected,
        events: _eventsByDay,
        completedEvents: completedEvents,
        pendingEvents: pendingEvents,
        dailyEvents: dailyEvents,
        weeklyEvents: weeklyEvents,
        monthlyEvents: monthlyEvents,
        selectedCategory: _selectedCategory,
      ),
    );
  }

  // Filtrelenmiş etkinlikleri döndüren getter
  List<Event> get _filteredEvents {
    if (_selectedCategory == null) {
      return _events;
    }
    return _events
        .where((event) => event.category == _selectedCategory)
        .toList();
  }

  Widget _buildCategoryGrid() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kategoriler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedCategory != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    icon: const Icon(
                      Icons.filter_alt_off,
                      color: Colors.white70,
                      size: 20,
                    ),
                    label: const Text(
                      'Filtreyi Kaldır',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == _categories.length) {
                  return _buildAddCategoryCard();
                }
                return _buildCategoryCard(_categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final isSelected = category['name'] == _selectedCategory;

    return Container(
      width: 120,
      margin: const EdgeInsets.all(4),
      child: Card(
        color: isSelected ? Colors.white : category['color'],
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : category['name'];
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  category['icon'],
                  color: isSelected ? category['color'] : Colors.white,
                  size: 32,
                ),
                const Spacer(),
                Text(
                  category['name'],
                  style: TextStyle(
                    color: isSelected ? category['color'] : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_events.where((e) => e.category == category['name']).length} Etkinlik',
                  style: TextStyle(
                    color: isSelected
                        ? category['color'].withOpacity(0.7)
                        : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCategoryCard() {
    return Container(
      width: 120,
      margin: const EdgeInsets.all(4),
      child: Card(
        color: Colors.white10,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        child: InkWell(
          onTap: () {
            // TODO: Yeni kategori ekleme
          },
          borderRadius: BorderRadius.circular(16),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.white70,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'Yeni\nKategori',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _filteredEvents;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedCategory == null
                          ? 'Henüz etkinlik eklenmemiş'
                          : '$_selectedCategory kategorisinde etkinlik bulunamadı',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final event = events[index];
          return EventListItem(
            event: event,
            onTap: () {
              // TODO: Etkinlik detay sayfasına git
            },
            onDelete: () async {
              await _eventRepository.deleteEvent(event.id);
              _loadEvents();
            },
          );
        },
        childCount: events.isEmpty ? 1 : events.length,
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 300),
      turns: _fabAnimationController.value,
      child: FloatingActionButton.extended(
        onPressed: () async {
          _fabAnimationController.forward(from: 0);
          final result = await Navigator.push<Event>(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddEventScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );

          if (result != null) {
            await _eventRepository.addEvent(result);
            _loadEvents();
          }
        },
        backgroundColor: Colors.white,
        icon: Icon(
          Icons.add_rounded,
          color: AppColors.primary,
          size: 32,
        ),
        label: Text(
          'Etkinlik Ekle',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
