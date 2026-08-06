import 'package:flutter/material.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';

/// Item de historial compacto para Wear OS Large Round.
class WearHistoryItem extends StatelessWidget {
  final WearTask task;

  const WearHistoryItem({super.key, required this.task});

  Color get _statusColor => switch (task.status) {
        WearTaskStatus.completed => const Color(0xFF4CAF50),
        WearTaskStatus.cancelled => const Color(0xFFF44336),
        _ => const Color(0xFF757575),
      };

  String get _durationLabel {
    if (task.completedAt == null) return '';
    final mins = task.completedAt!.difference(task.createdAt).inMinutes;
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: _statusColor, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hab. ${task.roomNumber} · ${task.taskType.label}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  task.description,
                  style: const TextStyle(fontSize: 9, color: Colors.white38),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status == WearTaskStatus.completed ? 'Hecho' : 'Cancel.',
                  style: TextStyle(
                    fontSize: 9,
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_durationLabel.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _durationLabel,
                  style: const TextStyle(fontSize: 9, color: Colors.white24),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}