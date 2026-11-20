import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_success_animation.dart';

/// Diálogo modal a pantalla completa para notificar una nueva tarea en Wear OS.
/// Optimizado para pantallas circulares con fuentes grandes, alto contraste
/// y botones de acción rápida de gran tamaño ("Recibido", "En camino", "Completado").
class WearTaskNotificationDialog extends ConsumerStatefulWidget {
  final WearTask task;

  const WearTaskNotificationDialog({super.key, required this.task});

  /// Muestra el diálogo de notificación de tarea en el reloj
  static Future<void> show(BuildContext context, WearTask task) {
    HapticFeedback.vibrate();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'WearTaskNotification',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, _, __) => WearTaskNotificationDialog(task: task),
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<WearTaskNotificationDialog> createState() =>
      _WearTaskNotificationDialogState();
}

class _WearTaskNotificationDialogState
    extends ConsumerState<WearTaskNotificationDialog> {
  late WearTask _currentTask;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 4) return const Color(0xFFFF3D00); // Rojo brillante
    if (priority == 3) return const Color(0xFFFFB300); // Ámbar brillante
    return const Color(0xFF00E676); // Verde brillante
  }

  String _getPriorityLabel(int priority) {
    if (priority >= 4) return 'Alta';
    if (priority == 3) return 'Media';
    return 'Baja';
  }

  Future<void> _handleAction(WearTaskStatus targetStatus) async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      if (targetStatus == WearTaskStatus.received) {
        await ref.read(markWearTaskReceivedProvider(_currentTask.id).future);
        if (mounted) {
          setState(() {
            _currentTask = _currentTask.copyWith(status: WearTaskStatus.received);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea marcada como Recibida', style: TextStyle(fontSize: 11)),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFF1976D2),
            ),
          );
        }
      } else if (targetStatus == WearTaskStatus.inProgress) {
        await ref.read(markWearTaskOnTheWayProvider(_currentTask.id).future);
        if (mounted) {
          setState(() {
            _currentTask = _currentTask.copyWith(status: WearTaskStatus.inProgress);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('En camino a la habitación', style: TextStyle(fontSize: 11)),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFFE65100),
            ),
          );
        }
      } else if (targetStatus == WearTaskStatus.completed) {
        await ref.read(completeWearTaskProvider((_currentTask.id, null)).future);
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          // Muestra la animación de éxito requerida en Escenario 2
          await WearSuccessAnimation.show(
            context,
            roomNumber: _currentTask.roomNumber,
            title: '¡Tarea Completada!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(fontSize: 10)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en la tarea si se actualiza desde otra parte
    final taskAsync = ref.watch(wearTaskByIdProvider(_currentTask.id));
    taskAsync.whenData((updated) {
      if (updated != null && updated.status != _currentTask.status && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _currentTask = updated);
        });
      }
    });

    final priorityColor = _getPriorityColor(_currentTask.priority);
    final priorityLabel = _getPriorityLabel(_currentTask.priority);

    // Padding optimizado para pantallas circulares Wear OS (450x450 / 390x390)
    const circularPadding = EdgeInsets.fromLTRB(20, 24, 20, 22);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        minimum: circularPadding,
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF00E676),
                  ),
                ),
              )
            : CustomScrollView(
                slivers: [
                  // Header: Alerta de Nueva Tarea con alto contraste
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFF5252),
                                  width: 1.2,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flash_on,
                                      size: 11, color: Color(0xFFFF5252)),
                                  SizedBox(width: 3),
                                  Text(
                                    'NUEVA TAREA',
                                    style: TextStyle(
                                      color: Color(0xFFFF5252),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Habitación con fuente extra grande
                        Text(
                          'Habitación ${_currentTask.roomNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),

                        // Chips de Prioridad y Tipo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: priorityColor, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flag, size: 10, color: priorityColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    'P${_currentTask.priority} · $priorityLabel',
                                    style: TextStyle(
                                      color: priorityColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cleaning_services,
                                      size: 10, color: Colors.white70),
                                  const SizedBox(width: 3),
                                  Text(
                                    _currentTask.taskType.label,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Descripción concisa
                  if (_currentTask.description.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _currentTask.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Estado actual indicador
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Estado actual: ${_currentTask.status.label}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // BOTONES DE ACCIÓN RÁPIDA DE GRAN TAMAÑO
                  // 1. "Recibido"
                  if (_currentTask.status == WearTaskStatus.pending) ...[
                    SliverToBoxAdapter(
                      child: _QuickActionButton(
                        label: 'Recibido',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF2979FF),
                        textColor: Colors.white,
                        onPressed: () => _handleAction(WearTaskStatus.received),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 7)),
                  ],

                  // 2. "En camino"
                  if (_currentTask.status == WearTaskStatus.pending ||
                      _currentTask.status == WearTaskStatus.received) ...[
                    SliverToBoxAdapter(
                      child: _QuickActionButton(
                        label: 'En camino',
                        icon: Icons.directions_walk_rounded,
                        color: const Color(0xFFFF9100),
                        textColor: Colors.black,
                        onPressed: () => _handleAction(WearTaskStatus.inProgress),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 7)),
                  ],

                  // 3. "Completado" (Terminado)
                  SliverToBoxAdapter(
                    child: _QuickActionButton(
                      label: 'Completado',
                      icon: Icons.task_alt_rounded,
                      color: const Color(0xFF00E676),
                      textColor: Colors.black,
                      height: 48,
                      onPressed: () => _handleAction(WearTaskStatus.completed),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // Botón Cerrar / Minimizar
                  SliverToBoxAdapter(
                    child: Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Ver más tarde',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }
}

/// Botón de acción rápida de gran tamaño para el wearable
class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final double height;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.height = 44,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

