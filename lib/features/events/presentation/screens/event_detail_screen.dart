import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/event_model.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.event.isCompleted ?? false;
  }

  void _toggleCompleted() {
    setState(() {
      _isCompleted = !_isCompleted;
    });

    // Yeni event objesi oluştur
    final updatedEvent = Event(
      id: widget.event.id,
      title: widget.event.title,
      description: widget.event.description,
      date: widget.event.date,
      time: widget.event.time,
      category: widget.event.category,
      location: widget.event.location,
      notes: widget.event.notes,
      isCompleted: _isCompleted,
    );

    // Değişiklikleri ana sayfaya bildir
    Navigator.pop(context, updatedEvent);
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Etkinliği Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu etkinliği silmek istediğinizden emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Repository üzerinden silme işlemi yapılacak
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pop(context); // Detay sayfasından çık
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _editEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(event: widget.event),
      ),
    );

    if (result != null) {
      // Değişiklikleri ana sayfaya bildir
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryInfo = _getCategoryInfo(widget.event.category);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editEvent,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'event_${widget.event.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              icon: categoryInfo['icon'] as IconData,
              color: categoryInfo['color'] as Color,
              title: 'Kategori',
              value: widget.event.category,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.calendar_today,
              color: Colors.blue,
              title: 'Tarih',
              value:
                  DateFormat('dd MMMM yyyy', 'tr_TR').format(widget.event.date),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.access_time,
              color: Colors.purple,
              title: 'Saat',
              value: widget.event.time.format(context),
            ),
            if (widget.event.location?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                color: Colors.red,
                title: 'Konum',
                value: widget.event.location!,
              ),
            ],
            if (widget.event.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 24),
              const Text(
                'Açıklama',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.description!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
            if (widget.event.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 24),
              const Text(
                'Notlar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.notes!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Modern Tamamlandı Butonu
            InkWell(
              onTap: () => _toggleCompleted(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isCompleted ? Colors.green : Colors.white24,
                    width: _isCompleted ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _isCompleted
                            ? Colors.green.withOpacity(0.15)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isCompleted ? Colors.green : Colors.white38,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: _isCompleted ? 1 : 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Metin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tamamlandı',
                            style: TextStyle(
                              color: _isCompleted ? Colors.green : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isCompleted
                                ? 'Bu etkinlik tamamlandı'
                                : 'Bu etkinlik henüz tamamlanmadı',
                            style: TextStyle(
                              color: _isCompleted
                                  ? Colors.green.withOpacity(0.7)
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // İkon
                    Icon(
                      _isCompleted
                          ? Icons.task_alt_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: _isCompleted ? Colors.green : Colors.white54,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(String category) {
    final categories = [
      {
        'name': 'Konser',
        'icon': Icons.music_note,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'name': 'Teknoloji',
        'icon': Icons.computer,
        'color': const Color(0xFFFFB84D),
      },
      {
        'name': 'Sinema',
        'icon': Icons.movie,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'name': 'Tiyatro',
        'icon': Icons.theater_comedy,
        'color': const Color(0xFF9B59B6),
      },
      {
        'name': 'Spor',
        'icon': Icons.sports_soccer,
        'color': const Color(0xFF2ECC71),
      },
    ];

    return categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => {
        'name': 'Diğer',
        'icon': Icons.category_outlined,
        'color': Colors.grey,
      },
    );
  }
}
