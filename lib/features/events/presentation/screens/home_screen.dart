import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import './add_event_screen.dart';
import '../../domain/models/event_model.dart';
import '../../data/repositories/event_repository.dart';
import '../widgets/event_list_item.dart';

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
    setState(() {
      _events = events;
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
            _buildDateBar(),
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

  Widget _buildDateBar() {
    final now = DateTime.now();
    final dates =
        List.generate(5, (index) => now.add(Duration(days: index - 2)));

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
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
                            'Bu Ay',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${_calculateTotalEvents()} Etkinlik',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_upward,
                                      color: Colors.greenAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '%${_calculateGrowthRate()}',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: _showCustomMonthPicker,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM yyyy', 'tr_TR')
                                    .format(_focusedDay),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(
                        icon: Icons.check_circle_outline,
                        label: 'Tamamlanan',
                        value: _calculateCompletedEvents(),
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 48),
                      _buildStatItem(
                        icon: Icons.pending_outlined,
                        label: 'Bekleyen',
                        value: _calculatePendingEvents(),
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dates.map((date) {
                final isSelected = date.day == now.day;
                return _buildDateItem(date, isSelected);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalEvents() {
    // Örnek veri
    return 12;
  }

  int _calculateGrowthRate() {
    // Örnek veri
    return 15;
  }

  int _calculateCompletedEvents() {
    // Örnek veri
    return 8;
  }

  int _calculatePendingEvents() {
    // Örnek veri
    return 4;
  }

  int _calculateThisWeekEvents() {
    // Örnek veri - Bu hafta içindeki etkinlik sayısı
    return 3;
  }

  Widget _buildDateItem(DateTime date, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDay = date;
          _focusedDay = date;
        });
      },
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              DateFormat('E', 'tr_TR').format(date).substring(0, 3),
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Kategoriler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
    return Container(
      width: 120,
      margin: const EdgeInsets.all(4),
      child: Card(
        color: category['color'],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = category['name'];
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
                  color: Colors.white,
                  size: 32,
                ),
                const Spacer(),
                Text(
                  category['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category['count']} Etkinlik',
                  style: const TextStyle(
                    color: Colors.white70,
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (_events.isEmpty) {
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
                      'Henüz etkinlik eklenmemiş',
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

          final event = _events[index];
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
        childCount: _events.isEmpty ? 1 : _events.length,
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

  void _showCustomMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'tr_TR').format(_focusedDay),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TableCalendar(
                firstDay: DateTime(2024),
                lastDay: DateTime(2025, 12),
                focusedDay: _focusedDay,
                currentDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                daysOfWeekHeight: 40,
                rowHeight: 40,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  Navigator.pop(context);
                },
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white70),
                  selectedTextStyle: TextStyle(color: AppColors.primary),
                  todayTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.white38),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime.now();
                        _selectedDay = DateTime.now();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Bugün',
                      style: TextStyle(color: Colors.white),
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
}
