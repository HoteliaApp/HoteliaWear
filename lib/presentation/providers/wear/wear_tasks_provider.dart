import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_repository_provider.dart';

/// Provider reactivo de todas las tareas (Stream en tiempo real desde Firebase)
final wearTasksProvider = StreamProvider<List<WearTask>>((ref) {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.watchTasks();
});

/// Provider reactivo de tareas pendientes
final wearPendingTasksProvider = Provider<AsyncValue<List<WearTask>>>((ref) {
  final tasksAsync = ref.watch(wearTasksProvider);
  return tasksAsync.whenData(
    (tasks) => tasks.where((t) => t.status == WearTaskStatus.pending).toList(),
  );
});

/// Provider reactivo de tareas en progreso
final wearInProgressTasksProvider = Provider<AsyncValue<List<WearTask>>>((ref) {
  final tasksAsync = ref.watch(wearTasksProvider);
  return tasksAsync.whenData(
    (tasks) =>
        tasks.where((t) => t.status == WearTaskStatus.inProgress).toList(),
  );
});

/// Provider reactivo de tareas completadas
final wearCompletedTasksProvider = Provider<AsyncValue<List<WearTask>>>((ref) {
  final tasksAsync = ref.watch(wearTasksProvider);
  return tasksAsync.whenData(
    (tasks) =>
        tasks.where((t) => t.status == WearTaskStatus.completed).toList(),
  );
});

/// Provider reactivo para obtener una tarea específica por ID
final wearTaskByIdProvider =
    Provider.family<AsyncValue<WearTask?>, String>((ref, taskId) {
  final tasksAsync = ref.watch(wearTasksProvider);
  return tasksAsync.whenData((tasks) {
    final matching = tasks.where((t) => t.id == taskId).toList();
    return matching.isNotEmpty ? matching.first : null;
  });
});

/// Provider reactivo de tareas recibidas
final wearReceivedTasksProvider = Provider<AsyncValue<List<WearTask>>>((ref) {
  final tasksAsync = ref.watch(wearTasksProvider);
  return tasksAsync.whenData(
    (tasks) =>
        tasks.where((t) => t.status == WearTaskStatus.received).toList(),
  );
});

/// Provider reactivo de tareas activas (Pendientes, Recibidas, En camino)
final wearActiveTasksProvider = Provider<AsyncValue<List<WearTask>>>((ref) {
  final tasksAsync = ref.watch(wearTasksProvider);
  return tasksAsync.whenData(
    (tasks) => tasks
        .where((t) =>
            t.status == WearTaskStatus.pending ||
            t.status == WearTaskStatus.received ||
            t.status == WearTaskStatus.inProgress)
        .toList(),
  );
});

/// Provider para marcar tarea como recibida ("Recibido")
final markWearTaskReceivedProvider =
    FutureProvider.family<void, String>((ref, taskId) async {
  final repository = ref.read(wearRepositoryProvider);
  await repository.markTaskAsReceived(taskId);
});

/// Provider para marcar tarea como en camino ("En camino")
final markWearTaskOnTheWayProvider =
    FutureProvider.family<void, String>((ref, taskId) async {
  final repository = ref.read(wearRepositoryProvider);
  await repository.markTaskAsOnTheWay(taskId);
});

/// Provider para manejar aceptación de tarea (compatible)
final acceptWearTaskProvider =
    FutureProvider.family<void, String>((ref, taskId) async {
  final repository = ref.read(wearRepositoryProvider);
  await repository.markTaskAsReceived(taskId);
});

/// Provider para iniciar tarea (compatible)
final startWearTaskProvider =
    FutureProvider.family<void, String>((ref, taskId) async {
  final repository = ref.read(wearRepositoryProvider);
  await repository.markTaskAsOnTheWay(taskId);
});

/// Provider para completar tarea
final completeWearTaskProvider =
    FutureProvider.family<void, (String, String?)>((ref, params) async {
  final (taskId, notes) = params;
  final repository = ref.read(wearRepositoryProvider);
  await repository.completeTask(taskId, notes: notes);
});

/// Provider para cancelar tarea
final cancelWearTaskProvider =
    FutureProvider.family<void, String>((ref, taskId) async {
  final repository = ref.read(wearRepositoryProvider);
  await repository.cancelTask(taskId);
});