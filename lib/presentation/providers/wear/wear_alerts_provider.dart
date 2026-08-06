import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_repository_provider.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';

/// Provider de todas las alertas
final wearAlertsProvider = FutureProvider<List<WearAlert>>((ref) async {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.getAlerts();
});

/// Provider de alertas sin reconocer
final wearUnacknowledgedAlertsProvider = FutureProvider<List<WearAlert>>((ref) async {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.getUnacknowledgedAlerts();
});

/// Provider para reconocer alerta
final acknowledgeWearAlertProvider = FutureProvider.family<void, String>((ref, alertId) async {
  final repository = ref.watch(wearRepositoryProvider);
  await repository.acknowledgeAlert(alertId);
  ref.invalidate(wearAlertsProvider);
  ref.invalidate(wearUnacknowledgedAlertsProvider);
});