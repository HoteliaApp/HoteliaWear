import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/infrastructure/models/wear/wear_task_model.dart';

void main() {
  group('[H-20] Flujo de Notificación y Modelos de Tarea', () {
    test('WearTaskModel parsea correctamente estado "received" / "recibido"', () {
      final json = {
        'id': 'task-101',
        'roomId': 'r-204',
        'roomNumber': 204,
        'taskType': 'cleaning',
        'status': 'received',
        'description': 'Limpieza completa y cambio de sábanas',
        'priority': 5,
        'isActive': true,
      };

      final model = WearTaskModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.id, equals('task-101'));
      expect(entity.roomNumber, equals(204));
      expect(entity.status, equals(WearTaskStatus.received));
      expect(entity.status.label, equals('Recibido'));
      expect(entity.isActive, isTrue);
      expect(entity.isReceived, isTrue);
      expect(entity.priority, equals(5));
    });

    test('WearTaskModel parsea estado "in_progress" o "en_camino" como inProgress', () {
      final json = {
        'id': 'task-102',
        'roomId': 'r-305',
        'roomNumber': 305,
        'taskType': 'cleaning',
        'status': 'en_camino',
        'description': 'Aspirar pasillo y cuarto',
        'priority': 4,
        'isActive': true,
      };

      final entity = WearTaskModel.fromJson(json).toEntity();

      expect(entity.status, equals(WearTaskStatus.inProgress));
      expect(entity.status.label, equals('En camino'));
      expect(entity.isInProgress, isTrue);
    });

    test('WearTaskModel parsea estado "completed" y refleja isCompleted', () {
      final json = {
        'id': 'task-103',
        'roomId': 'r-101',
        'roomNumber': 101,
        'taskType': 'cleaning',
        'status': 'completed',
        'description': 'Limpieza express',
        'priority': 3,
        'isActive': false,
      };

      final entity = WearTaskModel.fromJson(json).toEntity();

      expect(entity.status, equals(WearTaskStatus.completed));
      expect(entity.isCompleted, isTrue);
      expect(entity.isActive, isFalse);
    });

    test('WearTask copyWith permite transiciones de estado: Recibido -> En camino -> Completado', () {
      final initial = WearTask(
        id: 'task-flow',
        roomId: 'r-501',
        roomNumber: 501,
        taskType: WearTaskType.cleaning,
        status: WearTaskStatus.pending,
        description: 'Habitación VIP',
        createdAt: DateTime.now(),
        priority: 5,
        isActive: true,
      );

      // Paso 1: Camarista presiona "Recibido"
      final receivedTask = initial.copyWith(status: WearTaskStatus.received);
      expect(receivedTask.status, equals(WearTaskStatus.received));
      expect(receivedTask.isReceived, isTrue);

      // Paso 2: Camarista presiona "En camino"
      final onTheWayTask = receivedTask.copyWith(status: WearTaskStatus.inProgress);
      expect(onTheWayTask.status, equals(WearTaskStatus.inProgress));
      expect(onTheWayTask.isInProgress, isTrue);

      // Paso 3: Camarista presiona "Completado"
      final completedTask = onTheWayTask.copyWith(
        status: WearTaskStatus.completed,
        isActive: false,
        completedAt: DateTime.now(),
      );
      expect(completedTask.status, equals(WearTaskStatus.completed));
      expect(completedTask.isCompleted, isTrue);
      expect(completedTask.isActive, isFalse);
    });
  });
}

