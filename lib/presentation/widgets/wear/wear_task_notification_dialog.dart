import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_success_animation.dart';

/// Diálogo modal a pantalla completa para notificar una nueva tarea en Wear OS.
class WearTaskNotificationDialog extends ConsumerStatefulWidget {
  final WearTask task;

  const WearTaskNotificationDialog({super.key, required this.task});

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

  Color _getPriorityColor(BuildContext context, int priority) {
    final s = AppStatusColors.of(context);
    if (priority >= 4) return s.danger;
    if (priority == 3) return s.warning;
    return s.success;
  }

  String _getPriorityLabel(int priority) {
    if (priority >= 4) return 'Alta';
    if (priority == 3) return 'Media';
    return 'Baja';
  }

  Future<void> _handleAction(WearTaskStatus targetStatus) async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    final statusColors = AppStatusColors.of(context);

    try {
      if (targetStatus == WearTaskStatus.received) {
        await ref.read(markWearTaskReceivedProvider(_currentTask.id).future);
        if (mounted) {
          setState(() {
            _currentTask =
                _currentTask.copyWith(status: WearTaskStatus.received);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tarea marcada como Recibida'),
              duration: const Duration(seconds: 1),
              backgroundColor: statusColors.info,
            ),
          );
        }
      } else if (targetStatus == WearTaskStatus.inProgress) {
        await ref.read(markWearTaskOnTheWayProvider(_currentTask.id).future);
        if (mounted) {
          setState(() {
            _currentTask =
                _currentTask.copyWith(status: WearTaskStatus.inProgress);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('En camino a la habitación'),
              duration: Duration(seconds: 1),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else if (targetStatus == WearTaskStatus.completed) {
        await ref
            .read(completeWearTaskProvider((_currentTask.id, null)).future);
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
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
            content: Text('Error: $e'),
            backgroundColor: statusColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);

    final taskAsync = ref.watch(wearTaskByIdProvider(_currentTask.id));
    taskAsync.whenData((updated) {
      if (updated != null && updated.status != _currentTask.status && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _currentTask = updated);
        });
      }
    });

    final priorityColor = _getPriorityColor(context, _currentTask.priority);
    final priorityLabel = _getPriorityLabel(_currentTask.priority);

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        child: _isLoading
            ? Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: statusColors.success,
                  ),
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppPill(
                              label: 'NUEVA TAREA',
                              color: statusColors.danger,
                              icon: Icons.flash_on_rounded,
                              outlined: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs + 2),
                        Text(
                          'Habitación ${_currentTask.roomNumber}',
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppPill(
                              label: 'P${_currentTask.priority} · $priorityLabel',
                              color: priorityColor,
                              icon: Icons.flag_rounded,
                              outlined: true,
                            ),
                            const SizedBox(width: AppSpacing.xs + 2),
                            AppPill(
                              label: _currentTask.taskType.label,
                              color: statusColors.neutral,
                              icon: Icons.cleaning_services_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                  if (_currentTask.description.isNotEmpty)
                    SliverToBoxAdapter(
                      child: AppCard(
                        child: Text(
                          _currentTask.description,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                  SliverToBoxAdapter(
                    child: Center(
                      child: AppPill(
                        label: 'Estado actual: ${_currentTask.status.label}',
                        color: statusColors.neutral,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm + 2),
                  ),
                  if (_currentTask.status == WearTaskStatus.pending) ...[
                    SliverToBoxAdapter(
                      child: _QuickActionButton(
                        label: 'Recibido',
                        icon: Icons.check_circle_rounded,
                        color: statusColors.info,
                        textColor: Colors.black,
                        onPressed: () =>
                            _handleAction(WearTaskStatus.received),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 7)),
                  ],
                  if (_currentTask.status == WearTaskStatus.pending ||
                      _currentTask.status == WearTaskStatus.received) ...[
                    SliverToBoxAdapter(
                      child: _QuickActionButton(
                        label: 'En camino',
                        icon: Icons.directions_walk_rounded,
                        color: AppColors.primary,
                        textColor: Colors.white,
                        onPressed: () =>
                            _handleAction(WearTaskStatus.inProgress),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 7)),
                  ],
                  SliverToBoxAdapter(
                    child: _QuickActionButton(
                      label: 'Completado',
                      icon: Icons.task_alt_rounded,
                      color: statusColors.success,
                      textColor: Colors.black,
                      height: 48,
                      onPressed: () => _handleAction(WearTaskStatus.completed),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm + 2),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Ver más tarde',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                ],
              ),
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppIconSize.md, color: textColor),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
