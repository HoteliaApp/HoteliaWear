import 'package:hotel_wear_app/domain/datasource/wear/wear_datasource.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_notification.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';
import 'package:hotel_wear_app/domain/repositories/wear/wear_repository.dart';
import 'package:hotel_wear_app/config/services/wear_communication_service.dart';

/// Implementación del repositorio de wearable
class WearRepositoryImpl implements WearRepository {
  final WearDatasource datasource;
  final WearCommunicationService communicationService;

  WearRepositoryImpl({
    required this.datasource,
    required this.communicationService,
  });

  @override
  Future<List<WearTask>> getTasks() {
    return datasource.getTasks();
  }

  @override
  Future<WearTask?> getTaskById(String taskId) {
    return datasource.getTaskById(taskId);
  }

  @override
  Future<List<WearTask>> getTasksByStatus(WearTaskStatus status) {
    return datasource.getTasksByStatus(status);
  }

  @override
  Future<List<WearNotification>> getNotifications() {
    return datasource.getNotifications();
  }

  @override
  Future<List<WearNotification>> getUnreadNotifications() {
    return datasource.getUnreadNotifications();
  }

  @override
  Future<List<WearAlert>> getAlerts() {
    return datasource.getAlerts();
  }

  @override
  Future<List<WearAlert>> getUnacknowledgedAlerts() {
    return datasource.getUnacknowledgedAlerts();
  }

  @override
  Future<void> acceptTask(String taskId) async {
    await communicationService.acceptTask(taskId);
    // Actualizar estado local
    await datasource.updateTaskStatus(taskId, WearTaskStatus.pending);
  }

  @override
  Future<void> startTask(String taskId) async {
    await communicationService.startTask(taskId);
    await datasource.updateTaskStatus(taskId, WearTaskStatus.inProgress);
  }

  @override
  Future<void> completeTask(String taskId, {String? notes}) async {
    await communicationService.completeTask(taskId: taskId, notes: notes);
    await datasource.updateTaskStatus(taskId, WearTaskStatus.completed);
  }

  @override
  Future<void> cancelTask(String taskId) async {
    await communicationService.cancelTask(taskId);
    await datasource.updateTaskStatus(taskId, WearTaskStatus.cancelled);
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) {
    return datasource.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> acknowledgeAlert(String alertId) async {
    // TODO: Implementar lógica de reconocimiento
  }

  @override
  Stream<List<WearTask>> watchTasks() async* {
    yield await datasource.getTasks();
  }

  @override
  Stream<Map<String, dynamic>> getRealtimeUpdates() {
    return communicationService.receiveUpdates();
  }

  @override
  Stream<List<WearAlert>> watchAlerts() {
    return const Stream.empty();
  }
}
