import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
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
    final categoryInfo = _getCategoryInfo(event.category);
    final color = categoryInfo['color'] as Color;

    return Dismissible(
      key: Key(event.id),
      background: Container(
        color: Colors.red.withAlpha(51),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(51),
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCheckbox(color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(color),
                        if (event.description != null) ...[
                          const SizedBox(height: 4),
                          _buildDescription(),
                        ],
                        const SizedBox(height: 8),
                        _buildMetadata(categoryInfo),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Color color) {
    return GestureDetector(
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
          color: event.isCompleted ? color.withAlpha(38) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: event.isCompleted ? color : Colors.white38,
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
    );
  }

  Widget _buildTitle(Color color) {
    return Row(
      children: [
        Expanded(
          child: _buildHighlightedText(
            event.title,
            TextStyle(
              color: event.isCompleted ? Colors.white60 : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: event.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return _buildHighlightedText(
      event.description!,
      TextStyle(
        color: event.isCompleted ? Colors.white38 : Colors.white70,
        fontSize: 14,
        decoration: event.isCompleted ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildMetadata(Map<String, dynamic> categoryInfo) {
    return Row(
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
            categoryInfo['name'],
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
        if (event.time != null)
          Text(
            '${event.time!.hour.toString().padLeft(2, '0')}:${event.time!.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildHighlightedText(String text, TextStyle style) {
    if (searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final matches = searchQuery.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (start < text.length) {
      final index = text.toLowerCase().indexOf(matches, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + matches.length),
        style: style.copyWith(
          backgroundColor: Colors.yellow.withAlpha(76),
          color: Colors.black,
        ),
      ));

      start = index + matches.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  Map<String, dynamic> _getCategoryInfo(String category) {
    // Implement the logic to get category information based on the category
    // This is a placeholder and should be replaced with actual implementation
    return {
      'name': category,
      'color': Colors.blue, // Placeholder color, actual implementation needed
    };
  }
}
