import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';
import 'package:hotel_wear_app/presentation/providers/wear/wear_providers.dart';
import 'package:hotel_wear_app/presentation/widgets/shared/app_ui.dart';
import 'package:hotel_wear_app/presentation/widgets/wear/wear_alert_card.dart';

class WearAlertsScreen extends ConsumerWidget {
  static const String routeName = '/wear-alerts';

  const WearAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(wearAlertsProvider);
    final theme = Theme.of(context);
    final statusColors = AppStatusColors.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: AppSpacing.circularScreen,
        child: alertsAsync.when(
          data: (alerts) {
            if (alerts.isEmpty) {
              return AppEmptyState(
                icon: Icons.check_circle_rounded,
                color: statusColors.success,
                title: 'Sin alertas',
                message: 'Todo bajo control',
              );
            }

            final unacknowledged =
                alerts.where((a) => !a.isAcknowledged).toList();
            final acknowledged = alerts.where((a) => a.isAcknowledged).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_rounded,
                          size: AppIconSize.sm,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Alertas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (unacknowledged.isNotEmpty)
                          AppPill(
                            label: '${unacknowledged.length}',
                            color: statusColors.danger,
                            outlined: true,
                          ),
                      ],
                    ),
                  ),
                ),
                if (unacknowledged.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: AppSectionTitle(
                      title: 'Por reconocer',
                      color: statusColors.warning,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => WearAlertCard(
                        alert: unacknowledged[i],
                        onAcknowledge: () {
                          ref.read(
                            acknowledgeWearAlertProvider(unacknowledged[i].id),
                          );
                        },
                      ),
                      childCount: unacknowledged.length,
                    ),
                  ),
                ],
                if (acknowledged.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: AppSectionTitle(
                        title: 'Reconocidas',
                        color: statusColors.success,
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
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
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
            child: Text(
              'Error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
