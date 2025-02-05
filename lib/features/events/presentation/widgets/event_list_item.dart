import 'package:flutter/material.dart';
import '../../domain/models/event_model.dart';
import '../../../../core/theme/app_colors.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final String searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onCompletedChanged;

  const EventListItem({
    super.key,
    required this.event,
    required this.searchQuery,
    this.onTap,
    this.onDelete,
    this.onCompletedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(51),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
        ),
      ),
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: event.isCompleted
            ? Colors.green.withAlpha(13)
            : Colors.white.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: event.isCompleted
              ? BorderSide(
                  color: Colors.green.withAlpha(76),
                  width: 1,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (event.isCompleted)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tamamlandı',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildHighlightedText(
                                  event.title,
                                  TextStyle(
                                    color: event.isCompleted
                                        ? Colors.white60
                                        : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: event.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (event.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildHighlightedText(
                              event.description,
                              TextStyle(
                                color: event.isCompleted
                                    ? Colors.white38
                                    : Colors.white70,
                                fontSize: 14,
                                decoration: event.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _buildHighlightedText(
                                  event.category,
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (event.location != null) ...[
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildHighlightedText(
                                    event.location!,
                                    const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                              Text(
                                '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Modern Checkbox - Sağda
                    GestureDetector(
                      onTap: () {
                        if (onCompletedChanged != null) {
                          onCompletedChanged!(!event.isCompleted);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: event.isCompleted
                              ? Colors.green.withAlpha(38)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: event.isCompleted
                                ? Colors.green
                                : Colors.white38,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: event.isCompleted ? 1 : 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, TextStyle style) {
    if (searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final matches = searchQuery.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = text.toLowerCase().indexOf(matches, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: style));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + matches.length),
          style: style.copyWith(
            backgroundColor: Colors.yellowAccent.withAlpha(76),
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + matches.length;
    }

    return RichText(text: TextSpan(children: spans));
  }
}
