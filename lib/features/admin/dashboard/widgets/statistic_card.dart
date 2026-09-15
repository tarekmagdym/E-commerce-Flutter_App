import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.value,
    required this.label,
    this.changePercent,
  });

  final IconData icon;
  final Color iconBackground;
  final String value;
  final String label;

  /// Month-over-month % change from the backend's dashboard stats
  /// endpoint. Null hides the trend badge.
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconBackground, size: 18),
              ),
              if (changePercent != null) _TrendBadge(changePercent: changePercent!),
            ],
          ),
          const SizedBox(height: 12),
          // FIX: added maxLines + overflow so the value/label never clip
          // or get pushed out of the card on long numbers or larger
          // system text-scale settings. No font/size/color/weight changed.
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.changePercent});

  final double changePercent;

  @override
  Widget build(BuildContext context) {
    final isUp = changePercent >= 0;
    final color = isUp ? AppColors.success : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: color,
            size: 11,
          ),
          const SizedBox(width: 2),
          Text(
            '${changePercent.abs().toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}