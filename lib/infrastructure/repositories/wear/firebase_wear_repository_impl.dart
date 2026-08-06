import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_notification.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';
import 'package:hotel_wear_app/domain/repositories/wear/wear_repository.dart';
import 'package:hotel_wear_app/infrastructure/models/wear/wear_task_model.dart';
import 'package:hotel_wear_app/infrastructure/models/wear/wear_alert_model.dart';

/// Implementación de WearRepository con Firebase Firestore
class FirebaseWearRepositoryImpl implements WearRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de tareas activas desde Firestore
  @override
  Stream<List<WearTask>> watchTasks() {
    return _firestore
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WearTaskModel.fromJson(doc.data()).toEntity())
          .toList();
    });
  }

  @override
  Future<List<WearTask>> getTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      return snapshot.docs
          .map((doc) => WearTaskModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<WearTask?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (doc.exists) {
        return WearTaskModel.fromJson(doc.data()!).toEntity();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WearTask>> getTasksByStatus(WearTaskStatus status) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: status.name)
          .get();
      return snapshot.docs
          .map((doc) => WearTaskModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<WearNotification>> getNotifications() async {
    try {
      await _firestore.collection('notifications').get();
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<WearNotification>> getUnreadNotifications() async {
    return [];
  }

  @override
  Future<List<WearAlert>> getAlerts() async {
    try {
      final snapshot = await _firestore.collection('alerts').get();
      return snapshot.docs
          .map((doc) => WearAlertModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<WearAlert>> getUnacknowledgedAlerts() async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('isAcknowledged', isEqualTo: false)
          .get();
      return snapshot.docs
          .map((doc) => WearAlertModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<WearAlert>> watchAlerts() {
    return _firestore
        .collection('alerts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WearAlertModel.fromJson(doc.data()).toEntity())
          .toList();
    });
  }

  @override
  Future<void> acceptTask(String taskId) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'status': WearTaskStatus.inProgress.name});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> startTask(String taskId) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'status': WearTaskStatus.inProgress.name});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> completeTask(String taskId, {String? notes}) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': WearTaskStatus.completed.name,
        'completedAt': DateTime.now().toIso8601String(),
        if (notes != null) 'notes': notes,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelTask(String taskId) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'status': WearTaskStatus.cancelled.name});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    // TODO
  }

  @override
  Future<void> acknowledgeAlert(String alertId) async {
    try {
      await _firestore
          .collection('alerts')
          .doc(alertId)
          .update({'isAcknowledged': true});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>> getRealtimeUpdates() {
    return _firestore
        .collection('updates')
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : {});
  }
}