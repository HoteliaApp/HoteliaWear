import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/domain/entities/wear/shift_metrics.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';

/// Pantalla de Resumen de Productividad del Turno.
/// Diseñada para Wear OS con fuentes grandes, alto contraste
/// y vista del conteo de tareas completadas hoy vs tareas pendientes (Escenario 2).
class WearMetricsScreen extends ConsumerWidget {
  static const String routeName = '/wear-metrics';

  const WearMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(wearShiftMetricsProvider);

    // Padding seguro para pantalla circular Wear OS
    const circularPadding = EdgeInsets.fromLTRB(24, 38, 24, 34);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        minimum: circularPadding,
        child: metricsAsync.when(
          data: (metrics) => _MetricsBody(metrics: metrics),
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF00E676),
              ),
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              'Error al cargar métricas',
              style: TextStyle(color: Colors.red[400], fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsBody extends StatelessWidget {
  final ShiftMetrics metrics;

  const _MetricsBody({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header con icono y título
        SliverToBoxAdapter(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insights, size: 14, color: Color(0xFF69F0AE)),
                  const SizedBox(width: 5),
                  const Text(
                    'Mi Turno',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      metrics.completionPercentage,
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        // KPI PRINCIPAL (Escenario 2): Completadas Hoy vs Pendientes
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                // Completadas Hoy
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 13, color: Color(0xFF00E676)),
                          const SizedBox(width: 4),
                          Text(
                            '${metrics.completedToday}',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Completadas hoy',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Separador vertical
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white24,
                ),

                // Tareas Pendientes
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pending,
                              size: 13, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(
                            '${metrics.pendingToday}',
                            style: const TextStyle(
                              color: Color(0xFFFFB300),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Pendientes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Barra de progreso de avance del turno
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: metrics.completionRate.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFF222222),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00E676),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${metrics.totalTasksToday} tareas totales',
                    style: const TextStyle(color: Colors.white38, fontSize: 8),
                  ),
                  Text(
                    '${metrics.inProgressToday} en camino',
                    style: const TextStyle(color: Color(0xFFFF9100), fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Métricas de tiempo: Tiempo trabajado y promedio por habitación
        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 13, color: Colors.white38),
                      const SizedBox(height: 2),
                      Text(
                        metrics.formattedTotalTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Tiempo total',
                        style: TextStyle(color: Colors.white24, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.speed,
                          size: 13, color: Colors.white38),
                      const SizedBox(height: 2),
                      Text(
                        metrics.formattedAverageTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Promedio',
                        style: TextStyle(color: Colors.white24, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Espacio para los indicadores de página del PageView
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
