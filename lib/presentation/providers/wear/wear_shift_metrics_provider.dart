import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/domain/entities/wear/shift_metrics.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_repository_provider.dart';

/// Stream en tiempo real de todas las tareas del día actual
final wearTodayTasksProvider = StreamProvider<List<WearTask>>((ref) {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.watchTodayTasks();
});

/// Provider de métricas y estadísticas locales de productividad del turno.
/// Cumple la nota técnica: "Calcular estadísticas locales a partir del stream del día actual".
final wearShiftMetricsProvider = Provider<AsyncValue<ShiftMetrics>>((ref) {
  final tasksAsync = ref.watch(wearTodayTasksProvider);
  return tasksAsync.whenData((tasks) => ShiftMetrics.fromTasks(tasks));
});
