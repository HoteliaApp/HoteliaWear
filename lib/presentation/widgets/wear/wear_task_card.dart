import 'package:flutter/material.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';

/// Tarjeta compacta para Wear OS Large Round.
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

  Color _statusColor(BuildContext context) {
    final s = AppStatusColors.of(context);
    return switch (task.status) {
      WearTaskStatus.pending => s.warning,
      WearTaskStatus.received => s.info,
      WearTaskStatus.inProgress => AppColors.primary,
      WearTaskStatus.completed => s.success,
      WearTaskStatus.cancelled => s.neutral,
    };
  }

  IconData get _taskIcon => switch (task.taskType) {
        WearTaskType.cleaning => Icons.cleaning_services_rounded,
        WearTaskType.maintenance => Icons.build_rounded,
        WearTaskType.inspection => Icons.assignment_ind_rounded,
        WearTaskType.delivery => Icons.local_shipping_rounded,
        WearTaskType.guest_request => Icons.room_service_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);
    final color = _statusColor(context);

    return AppCard(
      accent: color,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_taskIcon, size: AppIconSize.sm - 1, color: color),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(
                  'Hab. ${task.roomNumber} · ${task.taskType.label}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppPill(label: task.status.label, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            task.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          if (task.status == WearTaskStatus.pending) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            Row(
              children: [
                if (onReceived != null || onAccept != null)
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: FilledButton(
                        onPressed: onReceived ?? onAccept,
                        style: FilledButton.styleFrom(
                          backgroundColor: statusColors.info,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Recibido'),
                      ),
                    ),
                  ),
                if (onOnTheWay != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: FilledButton(
                        onPressed: onOnTheWay,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('En camino'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ] else if (task.status == WearTaskStatus.received &&
              onOnTheWay != null) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: FilledButton.icon(
                onPressed: onOnTheWay,
                icon: const Icon(
                  Icons.directions_walk_rounded,
                  size: AppIconSize.xs + 2,
                ),
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                label: const Text('En camino'),
              ),
            ),
          ] else if (task.status == WearTaskStatus.inProgress &&
              onComplete != null) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: FilledButton.icon(
                onPressed: onComplete,
                icon: const Icon(
                  Icons.check_circle_rounded,
                  size: AppIconSize.xs + 2,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: statusColors.success,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                ),
                label: const Text('Completar'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
