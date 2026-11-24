import 'package:flutter/material.dart';
import 'package:hotel_wear_app/config/theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════════════════
//  HOTELIA UI KIT — WEAR OS (versión compacta para pantalla circular)
//  Copia de HoteliaMovil/lib/presentation/widgets/shared/app_ui.dart
// ════════════════════════════════════════════════════════════════════════════

class AppSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSize.xs, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: c),
            ),
          ),
        ],
      ),
    );
  }
}

class AppPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool outlined;

  const AppPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppAlpha.badge),
        borderRadius: AppRadius.mdAll,
        border: outlined ? Border.all(color: color.withValues(alpha: 0.45)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSize.xs - 1, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(label, style: style, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 28,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppAlpha.badge),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: iconSize ?? size * 0.52),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool tinted;

  const AppCard({
    super.key,
    required this.child,
    this.accent,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md - 2,
      vertical: AppSpacing.sm,
    ),
    this.margin,
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = accent != null
        ? accent!.withValues(alpha: AppAlpha.borderDark)
        : theme.dividerColor.withValues(alpha: 0.5);
    final bg = tinted && accent != null
        ? Color.alphaBlend(
            accent!.withValues(alpha: AppAlpha.tint),
            AppColors.surfaceDark,
          )
        : AppColors.surfaceDark;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: bg,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Color? color;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = color ?? cs.onSurfaceVariant.withValues(alpha: 0.6);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppIconSize.hero, color: c),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
