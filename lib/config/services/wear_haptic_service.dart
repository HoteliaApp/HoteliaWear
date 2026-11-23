import 'package:flutter/services.dart';

/// Servicio para controlar el feedback háptico y la vibración en Wear OS.
/// Integra el canal nativo con la API de Vibrator de Android y provee
/// fallback con HapticFeedback.
class WearHapticService {
  static const MethodChannel _channel =
      MethodChannel('com.hotelapp.hotel_wear_app/vibrator');

  /// Emite un patrón de doble vibración pulsante.
  /// Requerido en Escenario 1 para alertas de severidad alta
  /// o solicitudes de huésped (guest_request).
  static Future<void> playDoublePulseVibration() async {
    try {
      final result = await _channel.invokeMethod<bool>('vibrateDoublePulse');
      if (result != true) {
        await _fallbackDoublePulse();
      }
    } catch (_) {
      await _fallbackDoublePulse();
    }
  }

  /// Vibración de éxito para confirmación de tareas completadas
  static Future<void> playSuccessVibration() async {
    try {
      final result = await _channel.invokeMethod<bool>('vibrateSuccess');
      if (result != true) {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Vibración simple para toques en la UI
  static Future<void> playClickVibration([int durationMs = 60]) async {
    try {
      await _channel.invokeMethod<bool>('vibrate', {'duration': durationMs});
    } catch (_) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Fallback con HapticFeedback de Flutter cuando el canal nativo no responde
  static Future<void> _fallbackDoublePulse() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 140));
    await HapticFeedback.heavyImpact();
  }
}
