import 'package:flutter/material.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';

/// Tarjeta de alerta compacta para Wear OS Large Round.
class WearAlertCard extends StatelessWidget {
  final WearAlert alert;
  final VoidCallback onAcknowledge;

  const WearAlertCard({
    super.key,
    required this.alert,
    required this.onAcknowledge,
  });

  Color get _severityColor => switch (alert.severity) {
        AlertSeverity.low => const Color(0xFF2196F3),
        AlertSeverity.medium => const Color(0xFFFFEB3B),
        AlertSeverity.high => const Color(0xFFFF9800),
        AlertSeverity.critical => const Color(0xFFF44336),
      };

  IconData get _severityIcon => switch (alert.severity) {
        AlertSeverity.low => Icons.info_outline,
        AlertSeverity.medium => Icons.warning_amber_outlined,
        AlertSeverity.high => Icons.error_outline,
        AlertSeverity.critical => Icons.emergency_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final minutesAgo = DateTime.now().difference(alert.createdAt).inMinutes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: _severityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: _severityColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_severityIcon, size: 13, color: _severityColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _severityColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hace $minutesAgo min',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
              if (alert.isAcknowledged)
                const Text(
                  '✓ OK',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (!alert.isAcknowledged) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 26,
              child: ElevatedButton(
                onPressed: onAcknowledge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _severityColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Reconocer',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}