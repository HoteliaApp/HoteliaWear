import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/services/wear_communication_service.dart';
import 'package:hotel_wear_app/domain/repositories/wear/wear_repository.dart';
import 'package:hotel_wear_app/infrastructure/repositories/wear/firebase_wear_repository_impl.dart';
import 'package:hotel_wear_app/infrastructure/services/wear_communication_service_impl.dart';

/// Provider de WearCommunicationService (singleton)
final wearCommunicationServiceProvider = Provider<WearCommunicationService>((ref) {
  return WearCommunicationServiceImpl();
});

/// Provider de WearRepository conectado a Firebase Firestore en tiempo real
final wearRepositoryProvider = Provider<WearRepository>((ref) {
  return FirebaseWearRepositoryImpl();
});