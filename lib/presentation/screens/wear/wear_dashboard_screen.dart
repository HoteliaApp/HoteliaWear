import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_task_card.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_success_animation.dart';
import 'package:hotel_wear_app/presentation/screens/wear/wear_task_detail_screen.dart';

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
    final connectionStatus = ref
        .watch(wearCommunicationServiceProvider)
        .connectionStatus;

    // Padding circular para Wear OS Large Round (450x450 dp)
    const circularPadding = EdgeInsets.fromLTRB(28, 44, 28, 44);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        minimum: circularPadding,
        child: CustomScrollView(
          slivers: [
            // Header compacto con título y estado de conexión
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: connectionStatus,
                      builder: (_, status, __) => Row(
                        children: [
                          if (hasPendingSync) ...[
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 11,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'Sync',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: status.name == 'connected'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status.name == 'connected' ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 10,
                              color: status.name == 'connected'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sección: En Progreso / En camino
            const SliverToBoxAdapter(
              child: _SectionLabel(
                label: 'En camino / Progreso',
                icon: Icons.directions_walk,
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
                                completeWearTaskProvider((tasks[i].id, null)).future);
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
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.red[400], fontSize: 11),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Sección: Recibidas
            const SliverToBoxAdapter(
              child: _SectionLabel(
                label: 'Recibidas',
                icon: Icons.mark_email_read_outlined,
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
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.red[400], fontSize: 11),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Sección: Pendientes
            const SliverToBoxAdapter(
              child: _SectionLabel(
                label: 'Pendientes',
                icon: Icons.pending_outlined,
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
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.red[400], fontSize: 11),
                ),
              ),
            ),

            // Espacio final para el indicador de página
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.white54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final String text;
  const _EmptySlot({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white24, fontSize: 11),
      ),
    );
  }
}
