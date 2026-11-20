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
  final bool isSyncPending;

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
    this.isSyncPending = false,
  });

  /// Convierte documento/JSON de Firestore a modelo preservando metadata de sincronización
  factory WearTaskModel.fromFirestore(
    Map<String, dynamic> json, {
    String? id,
    bool isSyncPending = false,
  }) {
    return WearTaskModel(
      id: id ?? json['id'] ?? '',
      roomId: json['roomId'] ?? json['room_id'] ?? '',
      roomNumber: json['roomNumber'] ?? json['room_number'] ?? 0,
      taskType: json['taskType'] ?? json['task_type'] ?? 'cleaning',
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      assignedTo: json['assignedTo'] ?? json['assigned_to'],
      priority: json['priority'] ?? 3,
      isSyncPending: isSyncPending,
    );
  }

  /// Convierte JSON del API a modelo
  factory WearTaskModel.fromJson(Map<String, dynamic> json) {
    return WearTaskModel(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? json['room_id'] ?? '',
      roomNumber: json['roomNumber'] ?? json['room_number'] ?? 0,
      taskType: json['taskType'] ?? json['task_type'] ?? 'cleaning',
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      assignedTo: json['assignedTo'] ?? json['assigned_to'],
      priority: json['priority'] ?? 3,
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
      isSyncPending: isSyncPending,
    );
  }

  static WearTaskType _parseTaskType(String type) {
    return WearTaskType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => WearTaskType.cleaning,
    );
  }

  static WearTaskStatus _parseTaskStatus(String status) {
    return WearTaskStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => WearTaskStatus.pending,
    );
  }
}