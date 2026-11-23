import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_wear_app/config/services/wear_haptic_service.dart';
import 'package:hotel_wear_app/domain/entities/wear/shift_metrics.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/screens/wear/wear_metrics_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('[H-21] Resumen de Productividad del Turno (Métricas Locales)', () {
    test('Calcula correctamente completadas hoy vs tareas pendientes', () {
      final now = DateTime.now();
      final mockTasks = [
        WearTask(
          id: '1',
          roomId: 'r1',
          roomNumber: 101,
          taskType: WearTaskType.cleaning,
          status: WearTaskStatus.completed,
          description: 'Limpieza general',
          createdAt: now.subtract(const Duration(hours: 3)),
          completedAt: now.subtract(const Duration(hours: 2, minutes: 30)),
          isActive: false,
        ),
        WearTask(
          id: '2',
          roomId: 'r2',
          roomNumber: 102,
          taskType: WearTaskType.cleaning,
          status: WearTaskStatus.completed,
          description: 'Cambio de sábanas',
          createdAt: now.subtract(const Duration(hours: 2)),
          completedAt: now.subtract(const Duration(hours: 1, minutes: 40)),
          isActive: false,
        ),
        WearTask(
          id: '3',
          roomId: 'r3',
          roomNumber: 201,
          taskType: WearTaskType.cleaning,
          status: WearTaskStatus.pending,
          description: 'Limpieza profunda',
          createdAt: now.subtract(const Duration(minutes: 40)),
          isActive: true,
        ),
        WearTask(
          id: '4',
          roomId: 'r4',
          roomNumber: 202,
          taskType: WearTaskType.guest_request,
          status: WearTaskStatus.received,
          description: 'Toallas extra',
          createdAt: now.subtract(const Duration(minutes: 20)),
          isActive: true,
        ),
        WearTask(
          id: '5',
          roomId: 'r5',
          roomNumber: 205,
          taskType: WearTaskType.cleaning,
          status: WearTaskStatus.inProgress,
          description: 'En camino a la habitación',
          createdAt: now.subtract(const Duration(minutes: 10)),
          isActive: true,
        ),
      ];

      final metrics = ShiftMetrics.fromTasks(mockTasks);

      // Criterio Escenario 2: conteo de completadas hoy vs pendientes
      expect(metrics.completedToday, equals(2));
      expect(metrics.pendingToday, equals(2)); // pending (1) + received (1)
      expect(metrics.inProgressToday, equals(1));
      expect(metrics.totalTasksToday, equals(5));

      // Porcentaje de avance: 2/5 = 40%
      expect(metrics.completionRate, equals(0.4));
      expect(metrics.completionPercentage, equals('40%'));

      // Tiempos calculados
      expect(metrics.totalMinutesSpent, greaterThan(0));
      expect(metrics.averageMinutesPerRoom, greaterThan(0));
    });

    test('Maneja lista vacía sin divisiones por cero', () {
      final metrics = ShiftMetrics.fromTasks([]);

      expect(metrics.completedToday, equals(0));
      expect(metrics.pendingToday, equals(0));
      expect(metrics.inProgressToday, equals(0));
      expect(metrics.totalTasksToday, equals(0));
      expect(metrics.completionRate, equals(0.0));
      expect(metrics.completionPercentage, equals('0%'));
      expect(metrics.formattedTotalTime, equals('0m'));
    });
  });

  group('[H-21] Feedback Háptico Distintivo', () {
    test('WearHapticService ejecuta doble vibración pulsante sin errores (fallback seguro)', () async {
      // Verifica que no lance excepciones aunque no esté corriendo en un dispositivo físico WearOS
      await expectLater(
        WearHapticService.playDoublePulseVibration(),
        completes,
      );
    });

    test('WearHapticService ejecuta vibración de éxito y click sin excepciones', () async {
      await expectLater(WearHapticService.playSuccessVibration(), completes);
      await expectLater(WearHapticService.playClickVibration(50), completes);
    });
  });
}
