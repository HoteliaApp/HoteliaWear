/// Estados posibles de una tarea en el wearable
enum WearTaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get label => switch (this) {
        WearTaskStatus.pending => 'Pendiente',
        WearTaskStatus.inProgress => 'En Progreso',
        WearTaskStatus.completed => 'Completada',
        WearTaskStatus.cancelled => 'Cancelada',
      };
}

/// Tipos de tareas que puede recibir el wearable
enum WearTaskType {
  cleaning,
  maintenance,
  inspection,
  delivery,
  // ignore: constant_identifier_names
  guest_request;

  String get label => switch (this) {
        WearTaskType.cleaning => 'Limpieza',
        WearTaskType.maintenance => 'Mantenimiento',
        WearTaskType.inspection => 'Inspección',
        WearTaskType.delivery => 'Entrega',
        WearTaskType.guest_request => 'Solicitud de Huésped',
      };
}

/// Entidad WearTask — representa una tarea en el wearable
class WearTask {
  final String id;
  final String roomId;
  final int roomNumber;
  final WearTaskType taskType;
  final WearTaskStatus status;
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? assignedTo;
  final int priority; // 1-5, donde 5 es máxima prioridad

  const WearTask({
    required this.id,
    required this.roomId,
    required this.roomNumber,
    required this.taskType,
    required this.status,
    required this.description,
    required this.createdAt,
    this.completedAt,
    this.assignedTo,
    this.priority = 3,
  });

  /// Retorna true si la tarea está completada
  bool get isCompleted => status == WearTaskStatus.completed;

  /// Retorna true si la tarea está en progreso
  bool get isInProgress => status == WearTaskStatus.inProgress;

  /// Calcula el tiempo transcurrido desde que se creó
  Duration get elapsedTime => DateTime.now().difference(createdAt);

  /// Crea una copia con campos modificados
  WearTask copyWith({
    String? id,
    String? roomId,
    int? roomNumber,
    WearTaskType? taskType,
    WearTaskStatus? status,
    String? description,
    DateTime? createdAt,
    DateTime? completedAt,
    String? assignedTo,
    int? priority,
  }) {
    return WearTask(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
    );
  }

  @override
  String toString() =>
      'WearTask(id: $id, room: $roomNumber, type: ${taskType.label}, status: ${status.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WearTask && other.id == id;

  @override
  int get hashCode => id.hashCode;
}