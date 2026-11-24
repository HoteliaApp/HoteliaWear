import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/shift_metrics.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';

/// Pantalla de Resumen de Productividad del Turno.
class WearMetricsScreen extends ConsumerWidget {
  static const String routeName = '/wear-metrics';

  const WearMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(wearShiftMetricsProvider);
    final theme = Theme.of(context);
    final statusColors = AppStatusColors.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 38, 24, 34),
        child: metricsAsync.when(
          data: (metrics) => _MetricsBody(metrics: metrics),
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              'Error al cargar métricas',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColors.danger,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsBody extends StatelessWidget {
  final ShiftMetrics metrics;

  const _MetricsBody({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.insights_rounded,
                  size: AppIconSize.sm,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Mi Turno',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                AppPill(
                  label: metrics.completionPercentage,
                  color: statusColors.success,
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: AppIconSize.xs + 1,
                            color: statusColors.success,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${metrics.completedToday}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: statusColors.success,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Completadas hoy',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pending_rounded,
                            size: AppIconSize.xs + 1,
                            color: statusColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${metrics.pendingToday}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: statusColors.warning,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Pendientes',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppRadius.smAll,
                child: LinearProgressIndicator(
                  value: metrics.completionRate.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(statusColors.success),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${metrics.totalTasksToday} tareas totales',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${metrics.inProgressToday} en camino',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColors.info,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2,
                    vertical: AppSpacing.xs + 2,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: AppIconSize.xs + 1,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        metrics.formattedTotalTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tiempo total',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2,
                    vertical: AppSpacing.xs + 2,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: AppIconSize.xs + 1,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        metrics.formattedAverageTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Promedio',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }
}
