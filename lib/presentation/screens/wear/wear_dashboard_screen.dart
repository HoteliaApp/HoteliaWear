import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/screens/wear/wear_task_detail_screen.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_success_animation.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_task_card.dart';

class WearDashboardScreen extends ConsumerWidget {
  static const String routeName = '/wear-dashboard';
  static const String routePath = '/wear-dashboard';

  const WearDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTasksAsync = ref.watch(wearPendingTasksProvider);
    final receivedTasksAsync = ref.watch(wearReceivedTasksProvider);
    final inProgressTasksAsync = ref.watch(wearInProgressTasksProvider);
    final hasPendingSync = ref.watch(hasPendingSyncTasksProvider);
    final connectionStatus =
        ref.watch(wearCommunicationServiceProvider).connectionStatus;
    final theme = Theme.of(context);
    final statusColors = AppStatusColors.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: AppSpacing.circularScreen,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Panel',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: connectionStatus,
                      builder: (_, status, _) {
                        final isOnline = status.name == 'connected';
                        final connColor = isOnline
                            ? statusColors.success
                            : statusColors.danger;
                        return Row(
                          children: [
                            if (hasPendingSync) ...[
                              AppPill(
                                label: 'Sync',
                                color: statusColors.warning,
                                icon: Icons.cloud_upload_rounded,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: connColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: connColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── En camino / Progreso ──
            const SliverToBoxAdapter(
              child: AppSectionTitle(
                title: 'En camino / Progreso',
                icon: Icons.directions_walk_rounded,
              ),
            ),
            inProgressTasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const SliverToBoxAdapter(
                      child: _EmptySlot(text: 'Sin tareas en camino'),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => WearTaskCard(
                          task: tasks[i],
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WearTaskDetailScreen(taskId: tasks[i].id),
                            ),
                          ),
                          onComplete: () async {
                            await ref.read(
                              completeWearTaskProvider((tasks[i].id, null))
                                  .future,
                            );
                            if (ctx.mounted) {
                              WearSuccessAnimation.show(
                                ctx,
                                roomNumber: tasks[i].roomNumber,
                                title: '¡Completada!',
                              );
                            }
                          },
                        ),
                        childCount: tasks.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: _MiniLoader()),
              error: (e, _) => SliverToBoxAdapter(
                child: Text(
                  'Error',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColors.danger,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // ── Recibidas ──
            const SliverToBoxAdapter(
              child: AppSectionTitle(
                title: 'Recibidas',
                icon: Icons.mark_email_read_rounded,
              ),
            ),
            receivedTasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const SliverToBoxAdapter(
                      child: _EmptySlot(text: 'Sin tareas recibidas'),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => WearTaskCard(
                          task: tasks[i],
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WearTaskDetailScreen(taskId: tasks[i].id),
                            ),
                          ),
                          onOnTheWay: () {
                            ref.read(markWearTaskOnTheWayProvider(tasks[i].id));
                          },
                        ),
                        childCount: tasks.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: _MiniLoader()),
              error: (e, _) => SliverToBoxAdapter(
                child: Text(
                  'Error',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColors.danger,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // ── Pendientes ──
            const SliverToBoxAdapter(
              child: AppSectionTitle(
                title: 'Pendientes',
                icon: Icons.pending_rounded,
              ),
            ),
            pendingTasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const SliverToBoxAdapter(
                      child: _EmptySlot(text: 'Sin tareas pendientes'),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => WearTaskCard(
                          task: tasks[i],
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WearTaskDetailScreen(taskId: tasks[i].id),
                            ),
                          ),
                          onReceived: () {
                            ref.read(markWearTaskReceivedProvider(tasks[i].id));
                          },
                          onOnTheWay: () {
                            ref.read(markWearTaskOnTheWayProvider(tasks[i].id));
                          },
                        ),
                        childCount: tasks.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: _MiniLoader()),
              error: (e, _) => SliverToBoxAdapter(
                child: Text(
                  'Error',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColors.danger,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final String text;
  const _EmptySlot({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
