import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_repository_provider.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'wear_dashboard_screen.dart';
import 'wear_alerts_screen.dart';
import 'wear_history_screen.dart';

class WearMainScreen extends ConsumerStatefulWidget {
  const WearMainScreen({super.key});

  @override
  ConsumerState<WearMainScreen> createState() => _WearMainScreenState();
}

class _WearMainScreenState extends ConsumerState<WearMainScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wearCommunicationServiceProvider).initialize();
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
    // Escuchar nuevas alertas para navegar automáticamente
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nueva alerta recibida! Total: $currentCount')),
          );
          
          if (_currentPage != 1) {
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
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
                WearAlertsScreen(),
                WearHistoryScreen(),
              ],
            ),
            // Indicador de página circular en la parte inferior
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
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