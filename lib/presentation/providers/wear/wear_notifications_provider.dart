import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_notification.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_repository_provider.dart';

/// Provider de todas las notificaciones
final wearNotificationsProvider = FutureProvider<List<WearNotification>>((ref) async {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.getNotifications();
});

/// Provider de notificaciones sin leer
final wearUnreadNotificationsProvider = FutureProvider<List<WearNotification>>((ref) async {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.getUnreadNotifications();
});

/// Provider para marcar notificación como leída
final markNotificationAsReadProvider = FutureProvider.family<void, String>((ref, notificationId) async {
  final repository = ref.watch(wearRepositoryProvider);
  await repository.markNotificationAsRead(notificationId);
  ref.invalidate(wearNotificationsProvider);
  ref.invalidate(wearUnreadNotificationsProvider);
});

/// Provider para actualizaciones en tiempo real
final wearRealtimeUpdatesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(wearRepositoryProvider);
  return repository.getRealtimeUpdates();
});