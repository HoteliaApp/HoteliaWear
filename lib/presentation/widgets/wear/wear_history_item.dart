import 'package:flutter/material.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';

/// Item de historial compacto para Wear OS Large Round.
class WearHistoryItem extends StatelessWidget {
  final WearTask task;

  const WearHistoryItem({super.key, required this.task});

  Color _statusColor(BuildContext context) {
    final s = AppStatusColors.of(context);
    return switch (task.status) {
      WearTaskStatus.completed => s.success,
      WearTaskStatus.cancelled => s.danger,
      _ => s.neutral,
    };
  }

  String get _durationLabel {
    if (task.completedAt == null) return '';
    final mins = task.completedAt!.difference(task.createdAt).inMinutes;
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);
    final color = _statusColor(context);

    return AppCard(
      accent: color,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 2,
        vertical: AppSpacing.sm - 1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hab. ${task.roomNumber} · ${task.taskType.label}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  task.description,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppPill(
                label:
                    task.status == WearTaskStatus.completed ? 'Hecho' : 'Cancel.',
                color: color,
              ),
              if (_durationLabel.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _durationLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              if (task.isSyncPending) ...[
                const SizedBox(height: AppSpacing.xxs),
                AppPill(
                  label: 'Offline',
                  color: statusColors.warning,
                  icon: Icons.cloud_upload_rounded,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
