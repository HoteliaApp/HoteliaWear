import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotel_wear_app/config/services/wear_haptic_service.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_task.dart';
import 'package:hotel_wear_app/domain/entities/wear/wear_alert.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_task_notification_dialog.dart';
import 'wear_dashboard_screen.dart';
import 'wear_metrics_screen.dart';
import 'wear_alerts_screen.dart';
import 'wear_history_screen.dart';
import 'pin_login_screen.dart';

class WearMainScreen extends ConsumerStatefulWidget {
  const WearMainScreen({super.key});

  @override
  ConsumerState<WearMainScreen> createState() => _WearMainScreenState();
}

class _WearMainScreenState extends ConsumerState<WearMainScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Stream<DocumentSnapshot>? _userStream;
  bool _initializedTasks = false;
  final Set<String> _knownTaskIds = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wearCommunicationServiceProvider).initialize();
      _startSessionWatcher();
    });
  }

  Future<void> _startSessionWatcher() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('linkedUserId');
    if (userId == null) return;

    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();

    _userStream!.listen((snapshot) async {
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>?;
      // Si el documento existe pero el campo wearableLinkedAt fue borrado -> logout del movil
      final hasLinkedAt = data != null && data.containsKey('wearableLinkedAt');
      if (!hasLinkedAt) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('linkedUserId');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PinLoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar nuevas alertas para activar vibración y navegar
    ref.listen(wearUnacknowledgedAlertsProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stream alertas: ${next.error}')),
        );
      }

      if (next.hasValue && next.value != null) {
        final previousCount = previous?.value?.length ?? 0;
        final currentCount = next.value!.length;

        if (currentCount > previousCount) {
          final unacknowledged = next.value!;
          // Escenario 1 H-21: Alerta con severidad alta o solicitud de huésped
          final isUrgentAlert = unacknowledged.any((a) =>
              a.severity == AlertSeverity.high ||
              a.severity == AlertSeverity.critical ||
              a.message.toLowerCase().contains('huésped') ||
              a.message.toLowerCase().contains('huesped'));

          if (isUrgentAlert) {
            WearHapticService.playDoublePulseVibration();
          } else {
            HapticFeedback.vibrate();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nueva alerta recibida! Total: $currentCount'),
              backgroundColor: isUrgentAlert ? Colors.redAccent : null,
            ),
          );

          // Navegar a la página de alertas (índice 2)
          if (_currentPage != 2) {
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      }
    });

    // Escuchar stream /tasks filtrado por isActive == true para nuevas tareas
    ref.listen(wearTasksProvider, (previous, next) {
      if (!next.hasValue || next.value == null) return;
      final currentTasks = next.value!;

      // En la primera carga, registrar tareas conocidas
      if (!_initializedTasks) {
        _initializedTasks = true;
        for (final t in currentTasks) {
          _knownTaskIds.add(t.id);
        }
        // Si hay una tarea pendiente muy reciente al iniciar, notificar
        final recentPending = currentTasks.where((t) =>
            t.status == WearTaskStatus.pending &&
            DateTime.now().difference(t.createdAt).inMinutes < 2).toList();
        if (recentPending.isNotEmpty) {
          final task = recentPending.first;
          final isGuestRequest = task.taskType == WearTaskType.guest_request;
          final isHighPriority = task.priority >= 4;

          if (isGuestRequest || isHighPriority) {
            WearHapticService.playDoublePulseVibration();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              WearTaskNotificationDialog.show(context, task);
            }
          });
        }
        return;
      }

      // Detectar tareas recién creadas en Firestore
      final newTasks = currentTasks
          .where((t) => !_knownTaskIds.contains(t.id))
          .toList();

      for (final task in newTasks) {
        _knownTaskIds.add(task.id);
        // Escenario 1 H-21: Si es solicitud de huésped o alta prioridad, doble vibración pulsante
        final isGuestRequest = task.taskType == WearTaskType.guest_request;
        final isHighPriority = task.priority >= 4;

        if (isGuestRequest || isHighPriority) {
          WearHapticService.playDoublePulseVibration();
        } else {
          HapticFeedback.vibrate();
        }

        // Si es una tarea de limpieza o en estado pendiente
        if (task.taskType == WearTaskType.cleaning ||
            task.taskType == WearTaskType.guest_request ||
            task.status == WearTaskStatus.pending) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              WearTaskNotificationDialog.show(context, task);
            }
          });
          break; // Mostrar una por una
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _goToPreviousPage();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: const [
                WearDashboardScreen(),
                WearMetricsScreen(),
                WearAlertsScreen(),
                WearHistoryScreen(),
              ],
            ),
            // Indicador de página circular en la parte inferior (4 vistas)
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == i ? 8 : 5,
                    height: _currentPage == i ? 8 : 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}