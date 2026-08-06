import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_alert_card.dart';

class WearAlertsScreen extends ConsumerWidget {
  static const String routeName = '/wear-alerts';

  const WearAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(wearAlertsProvider);

    const circularPadding = EdgeInsets.fromLTRB(28, 44, 28, 44);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        minimum: circularPadding,
        child: alertsAsync.when(
          data: (alerts) {
            if (alerts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 36, color: Colors.green),
                    SizedBox(height: 10),
                    Text(
                      'Sin alertas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Todo bajo control',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final unacknowledged = alerts.where((a) => !a.isAcknowledged).toList();
            final acknowledged = alerts.where((a) => a.isAcknowledged).toList();

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_outlined,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        const Text(
                          'Alertas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (unacknowledged.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${unacknowledged.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (unacknowledged.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Por reconocer',
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => WearAlertCard(
                        alert: unacknowledged[i],
                        onAcknowledge: () {
                          ref.read(
                              acknowledgeWearAlertProvider(unacknowledged[i].id));
                        },
                      ),
                      childCount: unacknowledged.length,
                    ),
                  ),
                ],

                if (acknowledged.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 5),
                      child: Text(
                        'Reconocidas',
                        style: TextStyle(
                          color: Colors.green[300],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => WearAlertCard(
                        alert: acknowledged[i],
                        onAcknowledge: () {},
                      ),
                      childCount: acknowledged.length,
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Center(
            child: Text('Error',
                style: TextStyle(color: Colors.red[400], fontSize: 11)),
          ),
        ),
      ),
    );
  }
}