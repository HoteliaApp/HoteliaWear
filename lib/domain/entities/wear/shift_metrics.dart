import 'wear_task.dart';

/// Entidad que representa las métricas y KPI de productividad del turno actual
class ShiftMetrics {
  final int completedToday;
  final int pendingToday;
  final int inProgressToday;
  final int totalTasksToday;
  final double completionRate; // 0.0 a 1.0
  final int totalMinutesSpent;
  final double averageMinutesPerRoom;
  final DateTime shiftDate;

  const ShiftMetrics({
    required this.completedToday,
    required this.pendingToday,
    required this.inProgressToday,
    required this.totalTasksToday,
    required this.completionRate,
    required this.totalMinutesSpent,
    required this.averageMinutesPerRoom,
    required this.shiftDate,
  });

  /// Crea métricas calculadas a partir de una lista de tareas del turno/día
  factory ShiftMetrics.fromTasks(List<WearTask> tasks, {DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

    // Filtrar tareas que pertenecen al día actual (creadas o completadas hoy)
    final todayTasks = tasks.where((t) {
      final isCreatedToday =
          t.createdAt.isAfter(startOfDay) && t.createdAt.isBefore(endOfDay);
      final isCompletedToday = t.completedAt != null &&
          t.completedAt!.isAfter(startOfDay) &&
          t.completedAt!.isBefore(endOfDay);
      return isCreatedToday || isCompletedToday;
    }).toList();

    // Si no hay tareas de hoy con fecha estricta (por ejemplo mock o timezone),
    // usar todas las tareas activas y completadas de la lista disponible
    final effectiveTasks = todayTasks.isNotEmpty ? todayTasks : tasks;

    final completedTasks = effectiveTasks
        .where((t) => t.status == WearTaskStatus.completed)
        .toList();
    final pendingTasks = effectiveTasks
        .where((t) =>
            t.status == WearTaskStatus.pending ||
            t.status == WearTaskStatus.received)
        .toList();
    final inProgressTasks = effectiveTasks
        .where((t) => t.status == WearTaskStatus.inProgress)
        .toList();

    final completed = completedTasks.length;
    final pending = pendingTasks.length;
    final inProgress = inProgressTasks.length;
    final total = completed + pending + inProgress;
    final rate = total > 0 ? (completed / total) : 0.0;

    int totalMinutes = 0;
    for (final t in completedTasks) {
      if (t.completedAt != null) {
        final diff = t.completedAt!.difference(t.createdAt).inMinutes;
        totalMinutes += diff > 0 ? diff : 15; // Mínimo 15 min estimado
      } else {
        totalMinutes += 20;
      }
    }

    final avgMinutes =
        completed > 0 ? (totalMinutes / completed) : 0.0;

    return ShiftMetrics(
      completedToday: completed,
      pendingToday: pending,
      inProgressToday: inProgress,
      totalTasksToday: total,
      completionRate: rate,
      totalMinutesSpent: totalMinutes,
      averageMinutesPerRoom: avgMinutes,
      shiftDate: targetDate,
    );
  }

  /// Porcentaje formateado (ej. 75%)
  String get completionPercentage => '${(completionRate * 100).round()}%';

  /// Tiempo trabajado formateado (ej. 2h 30m o 45m)
  String get formattedTotalTime {
    if (totalMinutesSpent < 60) {
      return '${totalMinutesSpent}m';
    }
    final hours = totalMinutesSpent ~/ 60;
    final mins = totalMinutesSpent % 60;
    return '${hours}h ${mins}m';
  }

  /// Promedio por habitación formateado
  String get formattedAverageTime => '${averageMinutesPerRoom.round()} min/hab';
}
