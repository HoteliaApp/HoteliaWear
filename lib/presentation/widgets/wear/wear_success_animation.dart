import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Diálogo con animación de éxito optimizado para Wear OS.
/// Muestra un checkmark con rebote elástico, anillo de brillo pulsante
/// y tipografía de alto contraste sobre fondo negro puro (AMOLED).
class WearSuccessAnimation extends StatefulWidget {
  final int roomNumber;
  final String title;
  final VoidCallback? onDismissed;

  const WearSuccessAnimation({
    super.key,
    required this.roomNumber,
    this.title = '¡Completado!',
    this.onDismissed,
  });

  /// Muestra la animación de éxito a pantalla completa en Wear OS
  static Future<void> show(
    BuildContext context, {
    required int roomNumber,
    String title = '¡Completado!',
    VoidCallback? onDismissed,
  }) async {
    HapticFeedback.heavyImpact();
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'SuccessDialog',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return WearSuccessAnimation(
          roomNumber: roomNumber,
          title: title,
          onDismissed: onDismissed,
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
    onDismissed?.call();
  }

  @override
  State<WearSuccessAnimation> createState() => _WearSuccessAnimationState();
}

class _WearSuccessAnimationState extends State<WearSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _ringAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Auto-cierre suave tras completar la animación
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Anillo pulsante de onda verde
                        Opacity(
                          opacity: (1.0 - (_controller.value * 0.7)).clamp(0.0, 1.0),
                          child: Container(
                            width: 86 * _ringAnimation.value,
                            height: 86 * _ringAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00E676),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        // Contenedor principal del check
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFF00E676),
                                  Color(0xFF00B248),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x6600E676),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 44,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                // Título de éxito
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Subtítulo con habitación
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Habitación ${widget.roomNumber}',
                    style: const TextStyle(
                      color: Color(0xFF69F0AE),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

