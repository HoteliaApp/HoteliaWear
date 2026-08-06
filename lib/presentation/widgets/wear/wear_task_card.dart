import 'package:flutter/material.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';

/// Tarjeta compacta para Wear OS Large Round.
/// Diseñada para pantallas circulares de ~450x450dp.
class WearTaskCard extends StatelessWidget {
  final WearTask task;
  final VoidCallback onTap;
  final VoidCallback? onAccept;

  const WearTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onAccept,
  });

  Color get _statusColor => switch (task.status) {
        WearTaskStatus.pending => const Color(0xFFFF9800),
        WearTaskStatus.inProgress => const Color(0xFF2196F3),
        WearTaskStatus.completed => const Color(0xFF4CAF50),
        WearTaskStatus.cancelled => const Color(0xFF757575),
      };

  IconData get _taskIcon => switch (task.taskType) {
        WearTaskType.cleaning => Icons.cleaning_services,
        WearTaskType.maintenance => Icons.build,
        WearTaskType.inspection => Icons.assignment_ind,
        WearTaskType.delivery => Icons.local_shipping,
        WearTaskType.guest_request => Icons.room_service,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: _statusColor, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_taskIcon, size: 14, color: _statusColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Hab. ${task.roomNumber} · ${task.taskType.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
            if (task.status == WearTaskStatus.pending && onAccept != null) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 28,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}