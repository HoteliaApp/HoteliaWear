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

  /// Marca la tarea como "Recibido" (confirmada por ama de llaves)
  Future<void> markTaskAsReceived(String taskId);

  /// Inicia una tarea o la marca en estado "En camino"
  Future<void> startTask(String taskId);


  /// Completa una tarea. Retorna true si quedó guardada localmente pendiente de sincronizar (offline).
  Future<bool> completeTask(String taskId, {String? notes});

  /// Marca la tarea como "En camino"
  Future<void> markTaskAsOnTheWay(String taskId);

  /// Cancela una tarea
  Future<void> cancelTask(String taskId);

  /// Marca notificación como leída
  Future<void> markNotificationAsRead(String notificationId);

  /// Reconoce una alerta
  Future<void> acknowledgeAlert(String alertId);

  /// Stream de tareas activas en tiempo real (isActive == true)
  Stream<List<WearTask>> watchTasks();

  /// Stream de todas las tareas del día actual para métricas locales de productividad
  Stream<List<WearTask>> watchTodayTasks();

  /// Stream de actualizaciones en tiempo real
  Stream<Map<String, dynamic>> getRealtimeUpdates();
}
