import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/infrastructure/models/wear/wear_task_model.dart';

void main() {
  group('H-32: WearTask Offline & Resilience Tests', () {
    test('WearTask maneja correctamente isSyncPending por defecto y en copyWith', () {
      final task = WearTask(
        id: 't-101',
        roomId: 'r-101',
        roomNumber: 101,
        taskType: WearTaskType.cleaning,
        status: WearTaskStatus.pending,
        description: 'Limpieza de habitación',
        createdAt: DateTime.now(),
      );

      // Por defecto no tiene sincronización pendiente
      expect(task.isSyncPending, false);

      // Al completarse offline, isSyncPending se marca en true
      final completedOfflineTask = task.copyWith(
        status: WearTaskStatus.completed,
        completedAt: DateTime.now(),
        isSyncPending: true,
      );

      expect(completedOfflineTask.status, WearTaskStatus.completed);
      expect(completedOfflineTask.isCompleted, true);
      expect(completedOfflineTask.isSyncPending, true);

      // Al sincronizarse con Firestore, isSyncPending pasa a false
      final syncedTask = completedOfflineTask.copyWith(isSyncPending: false);
      expect(syncedTask.isSyncPending, false);
    });

    test('WearTaskModel.fromFirestore mapea correctamente metadata de sincronización offline', () {
      final json = {
        'id': 't-202',
        'roomId': 'r-202',
        'roomNumber': 202,
        'taskType': 'cleaning',
        'status': 'completed',
        'description': 'Limpieza general',
        'createdAt': DateTime.now().toIso8601String(),
        'completedAt': DateTime.now().toIso8601String(),
      };

      // Simula documento obtenido de la caché local antes de sincronizarse con el servidor
      final modelPending = WearTaskModel.fromFirestore(
        json,
        id: 't-202',
        isSyncPending: true,
      );
      final entityPending = modelPending.toEntity();
      expect(entityPending.isSyncPending, true);
      expect(entityPending.status, WearTaskStatus.completed);

      // Simula documento ya confirmado por el servidor Firestore
      final modelSynced = WearTaskModel.fromFirestore(
        json,
        id: 't-202',
        isSyncPending: false,
      );
      final entitySynced = modelSynced.toEntity();
      expect(entitySynced.isSyncPending, false);
    });
  });
}
