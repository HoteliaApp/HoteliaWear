import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_success_animation.dart';

/// Pantalla de confirmación/completar tarea — optimizada para Wear OS Large Round.
class WearConfirmationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/wear-confirmation';

  final WearTask task;

  const WearConfirmationScreen({super.key, required this.task});

  @override
  ConsumerState<WearConfirmationScreen> createState() =>
      _WearConfirmationScreenState();
}

class _WearConfirmationScreenState
    extends ConsumerState<WearConfirmationScreen> {
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _completeTask() async {
    setState(() => _isLoading = true);
    try {
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final isPendingSync = await ref.read(
        completeWearTaskProvider((widget.task.id, notes)).future,
      );
      if (!mounted) return;
      if (isPendingSync) {
        _showSuccess(isPendingSync: true);
      } else {
        await WearSuccessAnimation.show(
          context,
          roomNumber: widget.task.roomNumber,
          title: '¡Tarea Completada!',
        );
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppStatusColors.of(context).danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess({bool isPendingSync = false}) {
    final theme = Theme.of(context);
    final statusColors = AppStatusColors.of(context);
    final color = isPendingSync ? statusColors.warning : statusColors.success;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPendingSync
                    ? Icons.cloud_done_rounded
                    : Icons.check_circle_rounded,
                color: color,
                size: 36,
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                isPendingSync ? '¡Guardada localmente!' : '¡Completada!',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isPendingSync
                    ? 'Sin conexión a internet.\nSe sincronizará al conectar.'
                    : 'Sincronizada con el sistema.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              SizedBox(
                width: double.infinity,
                height: 30,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = AppStatusColors.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(26, 42, 26, 36),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: AppIconSize.sm,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Confirmar tarea',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm + 2)),
            SliverToBoxAdapter(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hab. ${widget.task.roomNumber} · ${widget.task.taskType.label}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.task.description,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.task.elapsedTime.inMinutes} min',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Prioridad ${widget.task.priority}/5',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            SliverToBoxAdapter(
              child: TextField(
                controller: _notesController,
                maxLines: 2,
                style: theme.textTheme.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Notas (opcional)...',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md - 2,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm + 2)),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _completeTask,
                        style: FilledButton.styleFrom(
                          backgroundColor: statusColors.success,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.zero,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('Completar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl + 6)),
          ],
        ),
      ),
    );
  }
}
