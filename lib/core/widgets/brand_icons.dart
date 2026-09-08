import 'package:flutter/material.dart';

/// Microsoft 4-square logo, drawn with the official brand colors.
class MicrosoftIcon extends StatelessWidget {
  const MicrosoftIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    final square = (size - 2) / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: square, height: square, color: const Color(0xFFF25022)),
              const SizedBox(width: 2),
              Container(width: square, height: square, color: const Color(0xFF7FBA00)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: square, height: square, color: const Color(0xFF00A4EF)),
              const SizedBox(width: 2),
              Container(width: square, height: square, color: const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Google "G" logo, approximated with a CustomPainter using the
/// official brand colors (blue / green / yellow / red).
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final strokeWidth = size.width * 0.24;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final green = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final yellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final red = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, -1.35, 1.7, false, blue);
    canvas.drawArc(rect, 0.35, 1.0, false, green);
    canvas.drawArc(rect, 1.35, 0.9, false, yellow);
    canvas.drawArc(rect, 2.25, 1.0, false, red);

    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - strokeWidth / 2, radius - strokeWidth * 0.3, strokeWidth),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}