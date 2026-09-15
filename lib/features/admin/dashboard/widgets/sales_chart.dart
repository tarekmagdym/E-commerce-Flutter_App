import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/admin_stats_model.dart';

/// Hand-drawn line chart (CustomPainter, no charting package) to
/// keep this dependency-free — matches the "no unnecessary packages"
/// rule for the project.
class SalesChart extends StatelessWidget {
  const SalesChart({
    super.key,
    required this.points,
    required this.range,
    required this.onRangeChanged,
  });

  final List<SalesPoint> points;

  /// 'week' | 'month' | 'year' — matches the backend's range query param.
  final String range;
  final ValueChanged<String> onRangeChanged;

  static const _ranges = ['week', 'month', 'year'];
  static const _rangeLabels = {
    'week': AppStrings.rangeWeekLabel,
    'month': AppStrings.rangeMonthLabel,
    'year': AppStrings.rangeYearLabel,
  };

  @override
  Widget build(BuildContext context) {
    final values = points.map((p) => p.revenue).toList();

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
              const Text(
                AppStrings.salesOverviewTitle,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              _RangeToggle(range: range, onChanged: onRangeChanged),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: _SalesLinePainter(values: values)),
          ),
        ],
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.range, required this.onChanged});

  final String range;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [for (final r in SalesChart._ranges) _buildOption(r)],
      ),
    );
  }

  Widget _buildOption(String r) {
    final isSelected = r == range;
    return GestureDetector(
      onTap: () => onChanged(r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          SalesChart._rangeLabels[r]!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SalesLinePainter extends CustomPainter {
  _SalesLinePainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // FIX: with exactly one data point, stepX was 0 and the point landed
    // near the bottom-left, and a Path with only a moveTo (no lineTo/
    // cubicTo) paints nothing — so the chart showed a single stray dot
    // instead of a populated-looking chart. Draw a flat reference line
    // at that value instead, using the same paint/colors as the normal
    // line, so a single-point range still reads as a real chart.
    if (values.length == 1) {
      final y = size.height / 2;
      final linePaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      canvas.drawCircle(Offset(size.width / 2, y), 3, Paint()..color = AppColors.primary);
      return;
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1 : (maxValue - minValue);

    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0.0;
    final points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          i * stepX,
          size.height - ((values[i] - minValue) / range) * size.height * 0.85 - size.height * 0.075,
        ),
    ];

    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = AppColors.primary.withOpacity(0.08));

    final dotPaint = Paint()..color = AppColors.primary;
    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SalesLinePainter oldDelegate) => oldDelegate.values != values;
}