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

  String _searchQuery = '';
  bool _isSearching = false;

  // Filtre seçenekleri
  bool? _isCompletedFilter;
  String? _dateFilter;

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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isSearching
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _isSearching = false;
                          });
                        },
                      )
                    : const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Başlık, açıklama veya konum ara...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _isSearching = value.isNotEmpty;
                    });
                  },
                ),
              ),
              if (_isSearching)
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                  },
                )
              else
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white70,
                      ),
                      onPressed: _showFilterDialog,
                    ),
                    if (_isCompletedFilter != null || _dateFilter != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
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
    List<Event> events = _events;

    // Kategori filtresi
    if (_selectedCategory != null) {
      events =
          events.where((event) => event.category == _selectedCategory).toList();
    }

    // Tamamlanma durumu filtresi
    if (_isCompletedFilter != null) {
      events = events
          .where((event) => event.isCompleted == _isCompletedFilter)
          .toList();
    }

    // Tarih filtresi
    if (_dateFilter != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (_dateFilter) {
        case 'today':
          events = events
              .where((event) =>
                  event.date.year == today.year &&
                  event.date.month == today.month &&
                  event.date.day == today.day)
              .toList();
          break;
        case 'week':
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));
          events = events
              .where((event) =>
                  event.date
                      .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                  event.date.isBefore(endOfWeek))
              .toList();
          break;
        case 'month':
          events = events
              .where((event) =>
                  event.date.year == today.year &&
                  event.date.month == today.month)
              .toList();
          break;
      }
    }

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      events = events.where((event) {
        return event.title.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            (event.location?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Tarihe göre sıralama (varsayılan)
    events.sort((a, b) => a.date.compareTo(b.date));

    return events;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrele',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Durum',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('Tümü'),
                      selected: _isCompletedFilter == null,
                      onSelected: (selected) {
                        setState(() => _isCompletedFilter = null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: AppColors.accent,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _isCompletedFilter == null
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Tamamlanan'),
                      selected: _isCompletedFilter == true,
                      onSelected: (selected) {
                        setState(
                            () => _isCompletedFilter = selected ? true : null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: const Color(0xFF4CAF50),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _isCompletedFilter == true
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Bekleyen'),
                      selected: _isCompletedFilter == false,
                      onSelected: (selected) {
                        setState(
                            () => _isCompletedFilter = selected ? false : null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: const Color(0xFFFF9800),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _isCompletedFilter == false
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tarih',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('Tümü'),
                      selected: _dateFilter == null,
                      onSelected: (selected) {
                        setState(() => _dateFilter = null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: AppColors.accent,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _dateFilter == null
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Bugün'),
                      selected: _dateFilter == 'today',
                      onSelected: (selected) {
                        setState(() => _dateFilter = selected ? 'today' : null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: const Color(0xFF2196F3),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _dateFilter == 'today'
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Bu Hafta'),
                      selected: _dateFilter == 'week',
                      onSelected: (selected) {
                        setState(() => _dateFilter = selected ? 'week' : null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: const Color(0xFF9C27B0),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _dateFilter == 'week'
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Bu Ay'),
                      selected: _dateFilter == 'month',
                      onSelected: (selected) {
                        setState(() => _dateFilter = selected ? 'month' : null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: const Color(0xFFE91E63),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _dateFilter == 'month'
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCompletedFilter = null;
                          _dateFilter = null;
                        });
                      },
                      child: const Text(
                        'Sıfırla',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        this.setState(() {}); // Ana ekranı güncelle
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      child: const Text('Uygula'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                      _buildEmptyMessage(),
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
            searchQuery: _searchQuery,
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

  String _buildEmptyMessage() {
    final List<String> filters = [];

    if (_searchQuery.isNotEmpty) {
      filters.add('"$_searchQuery" araması');
    }

    if (_selectedCategory != null) {
      filters.add('$_selectedCategory kategorisi');
    }

    if (_isCompletedFilter != null) {
      filters.add(_isCompletedFilter!
          ? 'tamamlanan etkinlikler'
          : 'bekleyen etkinlikler');
    }

    if (_dateFilter != null) {
      switch (_dateFilter) {
        case 'today':
          filters.add('bugünkü etkinlikler');
          break;
        case 'week':
          filters.add('bu haftaki etkinlikler');
          break;
        case 'month':
          filters.add('bu aydaki etkinlikler');
          break;
      }
    }

    if (filters.isEmpty) {
      return 'Henüz etkinlik eklenmemiş';
    }

    if (filters.length == 1) {
      return '${filters[0]} için etkinlik bulunamadı';
    }

    final lastFilter = filters.removeLast();
    return '${filters.join(", ")} ve $lastFilter için etkinlik bulunamadı';
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
