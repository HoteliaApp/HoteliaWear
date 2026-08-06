import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_repository_provider.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';

/// Provider de todas las alertas
final wearAlertsProvider = StreamProvider<List<WearAlert>>((ref) {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.watchAlerts();
});

/// Provider de alertas sin reconocer
final wearUnacknowledgedAlertsProvider = Provider<AsyncValue<List<WearAlert>>>((ref) {
  final alertsAsync = ref.watch(wearAlertsProvider);
  return alertsAsync.whenData(
    (alerts) => alerts.where((a) => !a.isAcknowledged).toList(),
  );
});

/// Provider para reconocer alerta
final acknowledgeWearAlertProvider = FutureProvider.family<void, String>((ref, alertId) async {
  final repository = ref.read(wearRepositoryProvider);
  await repository.acknowledgeAlert(alertId);
});