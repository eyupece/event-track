import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/event.dart';
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
    _isCompleted = widget.event.isCompleted;
  }

  void _toggleCompleted() {
    setState(() {
      _isCompleted = !_isCompleted;
    });

    // Yeni event objesi oluştur
    final updatedEvent = widget.event.copyWith(
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
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(event: widget.event),
      ),
    );

    if (!mounted) return;
    if (result != null) {
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
            if (widget.event.time != null)
              _buildInfoCard(
                icon: Icons.access_time,
                color: Colors.purple,
                title: 'Saat',
                value:
                    TimeOfDay.fromDateTime(widget.event.time!).format(context),
              ),
            if (widget.event.location != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                color: Colors.red,
                title: 'Konum',
                value: widget.event.location!,
              ),
            ],
            if (widget.event.description != null &&
                widget.event.description!.isNotEmpty) ...[
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
            if (widget.event.notes.isNotEmpty) ...[
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.event.notes
                    .map((note) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            note,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ))
                    .toList(),
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
                  color: Colors.white.withAlpha(25),
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
                            ? Colors.green.withAlpha(38)
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
                    Expanded(
                      child: Text(
                        _isCompleted ? 'Tamamlandı' : 'Tamamlanmadı',
                        style: TextStyle(
                          color: _isCompleted ? Colors.green : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle_outline,
                      color: _isCompleted ? Colors.green : Colors.white38,
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
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
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
    switch (category) {
      case 'Konser':
        return {
          'icon': Icons.music_note,
          'color': const Color(0xFFFF6B6B),
        };
      case 'Teknoloji':
        return {
          'icon': Icons.computer,
          'color': const Color(0xFFFFB84D),
        };
      case 'Sinema':
        return {
          'icon': Icons.movie,
          'color': const Color(0xFF4ECDC4),
        };
      case 'Tiyatro':
        return {
          'icon': Icons.theater_comedy,
          'color': const Color(0xFF9B59B6),
        };
      case 'Spor':
        return {
          'icon': Icons.sports_soccer,
          'color': const Color(0xFF2ECC71),
        };
      default:
        return {
          'icon': Icons.event,
          'color': Colors.grey,
        };
    }
  }
}
