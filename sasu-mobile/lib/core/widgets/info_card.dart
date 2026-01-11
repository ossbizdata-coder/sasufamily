/// InfoCard Widget
///
/// Purpose:
/// Reusable card to display a financial summary item.
///
/// UI:
/// - Rounded rectangle
/// - Soft elevation
/// - Optional leading icon
/// - Title (small text)
/// - Main value (large, bold)
/// - Optional subtitle (muted)
///
/// Must feel:
/// - Clean
/// - Premium
/// - Easy to read at a glance

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: gradient != null
              ? BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and title row
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (gradient != null ? Colors.white : iconColor ?? AppTheme.primaryGreen)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: gradient != null ? Colors.white : iconColor ?? AppTheme.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: gradient != null ? Colors.white.withOpacity(0.9) : AppTheme.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main value
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: gradient != null ? Colors.white : AppTheme.textDark,
                ),
              ),

              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: gradient != null ? Colors.white.withOpacity(0.8) : AppTheme.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

