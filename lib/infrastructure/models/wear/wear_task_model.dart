import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';

/// Modelo para mapear respuestas del API a WearTask
class WearTaskModel {
  final String id;
  final String roomId;
  final int roomNumber;
  final String taskType;
  final String status;
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? assignedTo;
  final int priority;
  final bool isActive;

  WearTaskModel({
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
    this.isActive = true,
  });

  /// Convierte JSON del API a modelo
  factory WearTaskModel.fromJson(Map<String, dynamic> json) {
    return WearTaskModel(
      id: json['id']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? json['room_id']?.toString() ?? '',
      roomNumber: json['roomNumber'] is int
          ? json['roomNumber'] as int
          : int.tryParse(json['roomNumber']?.toString() ??
                  json['room_number']?.toString() ??
                  '0') ??
              0,
      taskType: json['taskType']?.toString() ??
          json['task_type']?.toString() ??
          'cleaning',
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
      completedAt: _parseNullableDate(json['completedAt']),
      assignedTo: json['assignedTo']?.toString() ?? json['assigned_to']?.toString(),
      priority: json['priority'] is int
          ? json['priority'] as int
          : int.tryParse(json['priority']?.toString() ?? '3') ?? 3,
      isActive: json['isActive'] as bool? ??
          json['is_active'] as bool? ??
          true,
    );
  }

  /// Convierte modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'taskType': taskType,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'assignedTo': assignedTo,
      'priority': priority,
      'isActive': isActive,
    };
  }

  /// Convierte modelo a entidad de dominio
  WearTask toEntity() {
    return WearTask(
      id: id,
      roomId: roomId,
      roomNumber: roomNumber,
      taskType: _parseTaskType(taskType),
      status: _parseTaskStatus(status),
      description: description,
      createdAt: createdAt,
      completedAt: completedAt,
      assignedTo: assignedTo,
      priority: priority,
      isActive: isActive,
    );
  }

  static WearTaskType _parseTaskType(String type) {
    return WearTaskType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => WearTaskType.cleaning,
    );
  }

  static WearTaskStatus _parseTaskStatus(String status) {
    final clean = status.trim().toLowerCase();
    switch (clean) {
      case 'received':
      case 'recibido':
        return WearTaskStatus.received;
      case 'inprogress':
      case 'in_progress':
      case 'encamino':
      case 'en_camino':
      case 'en camino':
      case 'on_the_way':
        return WearTaskStatus.inProgress;
      case 'completed':
      case 'completado':
      case 'completada':
      case 'terminado':
      case 'terminada':
        return WearTaskStatus.completed;
      case 'cancelled':
      case 'cancelado':
      case 'cancelada':
        return WearTaskStatus.cancelled;
      case 'pending':
      case 'pendiente':
      default:
        return WearTaskStatus.pending;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}