import 'package:flutter/material.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';

/// Tarjeta compacta para Wear OS Large Round.
/// Diseñada para pantallas circulares de ~450x450dp.
class WearTaskCard extends StatelessWidget {
  final WearTask task;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReceived;
  final VoidCallback? onOnTheWay;
  final VoidCallback? onComplete;

  const WearTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onAccept,
    this.onReceived,
    this.onOnTheWay,
    this.onComplete,
  });

  Color get _statusColor => switch (task.status) {
        WearTaskStatus.pending => const Color(0xFFFF9800),
        WearTaskStatus.received => const Color(0xFF2979FF),
        WearTaskStatus.inProgress => const Color(0xFFFF9100),
        WearTaskStatus.completed => const Color(0xFF00E676),
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
            left: BorderSide(color: _statusColor, width: 3.5),
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
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.status.label,
                    style: TextStyle(
                      fontSize: 8,
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            // Botones de acción rápida en la tarjeta
            if (task.status == WearTaskStatus.pending) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (onReceived != null || onAccept != null)
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: onReceived ?? onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2979FF),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Recibido',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (onOnTheWay != null) ...[
                    const SizedBox(width: 4),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: onOnTheWay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9100),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'En camino',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ] else if (task.status == WearTaskStatus.received && onOnTheWay != null) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 28,
                child: ElevatedButton.icon(
                  onPressed: onOnTheWay,
                  icon: const Icon(Icons.directions_walk, size: 14),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9100),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  label: const Text(
                    'En camino',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else if (task.status == WearTaskStatus.inProgress && onComplete != null) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 28,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  label: const Text(
                    'Completar',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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