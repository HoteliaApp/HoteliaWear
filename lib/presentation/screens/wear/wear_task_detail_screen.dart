import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/screens/wear/wear_confirmation_screen.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';

/// Pantalla de detalle de una tarea — optimizada para Wear OS Large Round.
class WearTaskDetailScreen extends ConsumerWidget {
  static const String routeName = '/wear-task-detail';

  final String taskId;

  const WearTaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(wearTasksProvider);
    final theme = Theme.of(context);
    final statusColors = AppStatusColors.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(26, 42, 26, 36),
        child: tasksAsync.when(
          data: (tasks) {
            final matching = tasks.where((t) => t.id == taskId).toList();
            if (matching.isEmpty) {
              return AppEmptyState(
                icon: Icons.check_circle_rounded,
                color: statusColors.success,
                title: 'Completada',
              );
            }
            return _DetailBody(task: matching.first);
          },
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Center(
            child: Text(
              'Error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final WearTask task;
  const _DetailBody({required this.task});

  Color _priorityColor(BuildContext context, int p) {
    final s = AppStatusColors.of(context);
    if (p >= 4) return s.danger;
    if (p == 3) return s.warning;
    return s.success;
  }

  IconData _taskIcon(WearTaskType type) => switch (type) {
        WearTaskType.cleaning => Icons.cleaning_services_rounded,
        WearTaskType.maintenance => Icons.build_rounded,
        WearTaskType.inspection => Icons.search_rounded,
        WearTaskType.delivery => Icons.local_shipping_rounded,
        WearTaskType.guest_request => Icons.room_service_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);
    final pColor = _priorityColor(context, task.priority);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: AppIconSize.sm,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _taskIcon(task.taskType),
                    size: AppIconSize.sm,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Habitación ${task.roomNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppPill(
                    label: 'P${task.priority}',
                    color: pColor,
                    outlined: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                task.taskType.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm + 2)),

        SliverToBoxAdapter(
          child: AppCard(
            child: Text(
              task.description,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.timer_rounded,
                  value: '${task.elapsedTime.inMinutes}m',
                  label: 'Tiempo',
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: _InfoChip(
                  icon: Icons.flag_rounded,
                  value: task.status.label,
                  label: 'Estado',
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        if (task.status == WearTaskStatus.pending) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: statusColors.info,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(
                  Icons.check_circle_rounded,
                  size: AppIconSize.sm,
                ),
                label: const Text('Recibido'),
                onPressed: () {
                  ref.read(markWearTaskReceivedProvider(task.id));
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
        ],

        if (task.status == WearTaskStatus.pending ||
            task.status == WearTaskStatus.received) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton.icon(
                icon: const Icon(
                  Icons.directions_walk_rounded,
                  size: AppIconSize.sm,
                ),
                label: const Text('En camino'),
                onPressed: () {
                  ref.read(markWearTaskOnTheWayProvider(task.id));
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
        ],

        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            height: 38,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: statusColors.success,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.task_alt_rounded, size: AppIconSize.sm),
              label: const Text('Completar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WearConfirmationScreen(task: task),
                  ),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl + 6)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _InfoChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm - 1,
        horizontal: AppSpacing.xs,
      ),
      child: Column(
        children: [
          Icon(icon, size: AppIconSize.xs + 1, color: cs.onSurfaceVariant),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
