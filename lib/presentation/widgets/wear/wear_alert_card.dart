import 'package:flutter/material.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';

/// Tarjeta de alerta compacta para Wear OS Large Round.
class WearAlertCard extends StatelessWidget {
  final WearAlert alert;
  final VoidCallback onAcknowledge;

  const WearAlertCard({
    super.key,
    required this.alert,
    required this.onAcknowledge,
  });

  Color _severityColor(BuildContext context) {
    final s = AppStatusColors.of(context);
    return switch (alert.severity) {
      AlertSeverity.low => s.info,
      AlertSeverity.medium => s.warning,
      AlertSeverity.high => AppColors.primary,
      AlertSeverity.critical => s.danger,
    };
  }

  IconData get _severityIcon => switch (alert.severity) {
        AlertSeverity.low => Icons.info_rounded,
        AlertSeverity.medium => Icons.warning_amber_rounded,
        AlertSeverity.high => Icons.error_rounded,
        AlertSeverity.critical => Icons.emergency_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);
    final color = _severityColor(context);
    final minutesAgo = DateTime.now().difference(alert.createdAt).inMinutes;

    return AppCard(
      accent: color,
      tinted: true,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_severityIcon, size: AppIconSize.xs + 1, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  alert.message,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hace $minutesAgo min',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              if (alert.isAcknowledged)
                AppPill(
                  label: 'OK',
                  color: statusColors.success,
                  icon: Icons.check_rounded,
                ),
            ],
          ),
          if (!alert.isAcknowledged) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            SizedBox(
              width: double.infinity,
              height: 26,
              child: FilledButton(
                onPressed: onAcknowledge,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Reconocer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
