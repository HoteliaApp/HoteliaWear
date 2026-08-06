import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_notification.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';

/// Contrato para operaciones de wearable
abstract class WearRepository {
  /// Obtiene todas las tareas
  Future<List<WearTask>> getTasks();

  /// Obtiene una tarea
  Future<WearTask?> getTaskById(String taskId);

  /// Obtiene tareas por estado
  Future<List<WearTask>> getTasksByStatus(WearTaskStatus status);

  /// Obtiene notificaciones
  Future<List<WearNotification>> getNotifications();

  /// Obtiene notificaciones sin leer
  Future<List<WearNotification>> getUnreadNotifications();

  /// Obtiene alertas
  Future<List<WearAlert>> getAlerts();

  /// Obtiene alertas sin reconocer
  Future<List<WearAlert>> getUnacknowledgedAlerts();

  /// Stream de alertas en tiempo real
  Stream<List<WearAlert>> watchAlerts();

  /// Acepta una tarea
  Future<void> acceptTask(String taskId);

  /// Inicia una tarea
  Future<void> startTask(String taskId);

  /// Completa una tarea
  Future<void> completeTask(String taskId, {String? notes});

  /// Cancela una tarea
  Future<void> cancelTask(String taskId);

  /// Marca notificación como leída
  Future<void> markNotificationAsRead(String notificationId);

  /// Reconoce una alerta
  Future<void> acknowledgeAlert(String alertId);

  /// Stream de tareas en tiempo real
  Stream<List<WearTask>> watchTasks();

  /// Stream de actualizaciones en tiempo real
  Stream<Map<String, dynamic>> getRealtimeUpdates();
}