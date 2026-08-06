import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/screens/wear/wear_confirmation_screen.dart';

/// Pantalla de detalle de una tarea — optimizada para Wear OS Large Round.
class WearTaskDetailScreen extends ConsumerWidget {
  static const String routeName = '/wear-task-detail';

  final String taskId;

  const WearTaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(wearTasksProvider);

    const circularPadding = EdgeInsets.fromLTRB(26, 42, 26, 36);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        minimum: circularPadding,
        child: tasksAsync.when(
          data: (tasks) {
            final matching = tasks.where((t) => t.id == taskId).toList();
            if (matching.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Completada',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
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
            child: Text('Error',
                style: TextStyle(color: Colors.red[400], fontSize: 11)),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final WearTask task;
  const _DetailBody({required this.task});

  Color _priorityColor(int p) {
    if (p >= 4) return const Color(0xFFF44336);
    if (p == 3) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }

  IconData _taskIcon(WearTaskType type) => switch (type) {
        WearTaskType.cleaning => Icons.cleaning_services,
        WearTaskType.maintenance => Icons.build,
        WearTaskType.inspection => Icons.search,
        WearTaskType.delivery => Icons.local_shipping,
        WearTaskType.guest_request => Icons.room_service,
      };

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header: icono + habitación + prioridad
        SliverToBoxAdapter(
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        size: 14, color: Colors.white54),
                  ),
                  const SizedBox(width: 4),
                  Icon(_taskIcon(task.taskType),
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Habitación ${task.roomNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: _priorityColor(task.priority), width: 1),
                    ),
                    child: Text(
                      'P${task.priority}',
                      style: TextStyle(
                        fontSize: 9,
                        color: _priorityColor(task.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                task.taskType.label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // Descripción
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.description,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Tiempo + Estado
        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.timer_outlined,
                  value: '${task.elapsedTime.inMinutes}m',
                  label: 'Tiempo',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _InfoChip(
                  icon: Icons.flag_outlined,
                  value: task.status.label,
                  label: 'Estado',
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Botón Completar
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle_outline, size: 15),
              label: const Text(
                'Completar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
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

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _InfoChip(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 13, color: Colors.white38),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label,
              style:
                  const TextStyle(color: Colors.white24, fontSize: 9)),
        ],
      ),
    );
  }
}
