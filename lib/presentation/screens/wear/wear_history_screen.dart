import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_history_item.dart';

class WearHistoryScreen extends ConsumerWidget {
  static const String routeName = '/wear-history';

  const WearHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(wearTasksProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: AppSpacing.circularScreen,
        child: tasksAsync.when(
          data: (tasks) {
            final history = tasks
                .where(
                  (t) =>
                      t.status == WearTaskStatus.completed ||
                      t.status == WearTaskStatus.cancelled,
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (history.isEmpty) {
              return const AppEmptyState(
                icon: Icons.history_rounded,
                title: 'Sin historial',
                message: 'Las tareas completadas\naparecerán aquí',
              );
            }

            final grouped = <String, List<WearTask>>{};
            for (final task in history) {
              final dateKey =
                  '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}';
              grouped.putIfAbsent(dateKey, () => []).add(task);
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: AppIconSize.sm,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Historial',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${history.length} tareas',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                for (final entry in grouped.entries) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.xs,
                        top: AppSpacing.xs,
                      ),
                      child: Text(
                        entry.key,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => WearHistoryItem(task: entry.value[i]),
                      childCount: entry.value.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              ],
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Center(
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
