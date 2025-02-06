import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import './event_form_screen.dart';
import '../../domain/models/event.dart';
import '../widgets/event_list_item.dart';
import '../widgets/mini_calendar_widget.dart';
import './event_detail_screen.dart';
import '../widgets/success_animation_widget.dart';
import '../../data/providers/event_provider.dart';

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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late AnimationController _fabAnimationController;
  String? _selectedCategory;
  final String userName = "Eyüp";
  Map<DateTime, List<Event>> _eventsByDay = {};

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Konser',
      'icon': Icons.music_note,
      'color': Color(0xFFFF6B6B),
      'count': 5,
    },
    {
      'name': 'Teknoloji',
      'icon': Icons.computer,
      'color': Color(0xFFFFB84D),
      'count': 1,
    },
    {
      'name': 'Sinema',
      'icon': Icons.movie,
      'color': Color(0xFF4ECDC4),
      'count': 2,
    },
    {
      'name': 'Tiyatro',
      'icon': Icons.theater_comedy,
      'color': Color(0xFF9B59B6),
      'count': 0,
    },
    {
      'name': 'Spor',
      'icon': Icons.sports_soccer,
      'color': Color(0xFF2ECC71),
      'count': 0,
    },
  ];

  String _searchQuery = '';
  bool? _isCompletedFilter;
  String? _dateFilter;
  bool _showSuccessAnimation = false;
  Event? _lastDeletedEvent;
  int? _lastDeletedEventIndex;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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

  void _showAddSuccess() {
    setState(() {
      _showSuccessAnimation = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showSuccessAnimation = false;
        });
      }
    });
  }

  Future<void> _addEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EventFormScreen(),
      ),
    );

    if (result != null && mounted) {
      ref.read(eventProvider.notifier).addEvent(result);
      _showAddSuccess();
    }
  }

  // Filtrelenmiş etkinlikleri döndüren getter
  List<Event> get _filteredEvents {
    final events = ref.read(eventProvider);
    var filteredList = List<Event>.from(events);

    // Kategori filtresi
    if (_selectedCategory != null) {
      filteredList = filteredList
          .where((event) => event.category == _selectedCategory)
          .toList();
    }

    // Tamamlanma durumu filtresi
    if (_isCompletedFilter != null) {
      filteredList = filteredList
          .where((event) => event.isCompleted == _isCompletedFilter)
          .toList();
    }

    // Tarih filtresi
    if (_dateFilter != null) {
      final now = DateTime.now();
      switch (_dateFilter) {
        case 'today':
          filteredList = filteredList
              .where((event) =>
                  event.date.year == now.year &&
                  event.date.month == now.month &&
                  event.date.day == now.day)
              .toList();
          break;
        case 'week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          filteredList = filteredList
              .where((event) =>
                  event.date.isAfter(weekStart) && event.date.isBefore(weekEnd))
              .toList();
          break;
        case 'month':
          filteredList = filteredList
              .where((event) =>
                  event.date.year == now.year && event.date.month == now.month)
              .toList();
          break;
      }
    }

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList
          .where((event) =>
              event.title.toLowerCase().contains(query) ||
              (event.description?.toLowerCase().contains(query) ?? false) ||
              (event.location?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return filteredList;
  }

  void _updateEventsByDay() {
    final events = ref.read(eventProvider);
    final newEventsByDay = <DateTime, List<Event>>{};

    for (var event in events) {
      final day = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (newEventsByDay[day] == null) {
        newEventsByDay[day] = [];
      }
      newEventsByDay[day]!.add(event);
    }

    setState(() {
      _eventsByDay = newEventsByDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateEventsByDay();

    return Stack(
      children: [
        Scaffold(
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
        ),
        if (_showSuccessAnimation)
          SuccessAnimationWidget(
            onAnimationComplete: () {
              setState(() {
                _showSuccessAnimation = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba, $userName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Etkinliklerini takip et',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Etkinlik ara...',
            hintStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.search, color: Colors.white60),
            filled: true,
            fillColor: Colors.white.withAlpha(25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCalendar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MiniCalendarWidget(
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          onDaySelected: _onDaySelected,
          events: _eventsByDay,
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = _categories[index];
            final isSelected = category['name'] == _selectedCategory;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory =
                      isSelected ? null : category['name'] as String;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (category['color'] as Color).withAlpha(51)
                      : Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? category['color'] as Color
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected
                          ? category['color'] as Color
                          : Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? category['color'] as Color
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filteredEvents.where((e) => e.category == category['name']).length} Etkinlik',
                      style: TextStyle(
                        color: isSelected
                            ? (category['color'] as Color).withAlpha(179)
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: _categories.length,
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final filteredEvents = _filteredEvents;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final event = filteredEvents[index];
          return EventListItem(
            event: event,
            searchQuery: _searchQuery,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
              if (result != null) {
                ref.read(eventProvider.notifier).updateEvent(result);
                _updateEventsByDay();
              }
            },
            onDelete: () {
              _lastDeletedEvent = event;
              _lastDeletedEventIndex = index;
              ref.read(eventProvider.notifier).deleteEvent(event.id);
              _showUndoSnackBar();
              _updateEventsByDay();
            },
            onCompletedChanged: (value) {
              final updatedEvent = event.copyWith(
                isCompleted: value,
              );
              ref.read(eventProvider.notifier).updateEvent(updatedEvent);
              _updateEventsByDay();
            },
          );
        },
        childCount: filteredEvents.length,
      ),
    );
  }

  void _showUndoSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Etkinlik silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            if (_lastDeletedEvent != null && _lastDeletedEventIndex != null) {
              ref.read(eventProvider.notifier).addEvent(_lastDeletedEvent!);
              _updateEventsByDay();
              _lastDeletedEvent = null;
              _lastDeletedEventIndex = null;
            }
          },
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _addEvent,
      backgroundColor: AppColors.accent,
      child: const Icon(Icons.add),
    );
  }
}
