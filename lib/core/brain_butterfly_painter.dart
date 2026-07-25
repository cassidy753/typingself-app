import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

class BrainPainter extends CustomPainter {
  const BrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final hw = size.width * 0.38;
    final hh = size.height * 0.38;

    // Left hemisphere
    canvas.drawPath(Path()
      ..moveTo(cx, cy - hh * 0.2)
      ..cubicTo(cx - hw * 0.2, cy - hh * 1.2, cx - hw * 1.3, cy - hh * 0.4, cx - hw * 0.9, cy + hh * 0.3)
      ..cubicTo(cx - hw * 0.7, cy + hh * 0.7, cx - hw * 0.1, cy + hh * 0.5, cx, cy + hh * 0.1)..close(), paint);

    // Right hemisphere
    canvas.drawPath(Path()
      ..moveTo(cx, cy - hh * 0.2)
      ..cubicTo(cx + hw * 0.2, cy - hh * 1.2, cx + hw * 1.3, cy - hh * 0.4, cx + hw * 0.9, cy + hh * 0.3)
      ..cubicTo(cx + hw * 0.7, cy + hh * 0.7, cx + hw * 0.1, cy + hh * 0.5, cx, cy + hh * 0.1)..close(), paint);

    // Fissure
    final line = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.08)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, cy - hh * 0.8), Offset(cx, cy + hh * 0.3), line);

    // Folds
    final fold = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.06)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (final y in [-0.3, 0.0, 0.25]) {
      canvas.drawArc(Rect.fromCenter(center: Offset(cx - hw * 0.45, cy + y * hh), width: hw * 0.6, height: hh * 0.3), math.pi * 0.2, math.pi * 0.6, false, fold);
      canvas.drawArc(Rect.fromCenter(center: Offset(cx + hw * 0.45, cy + y * hh), width: hw * 0.6, height: hh * 0.3), math.pi * 1.2, math.pi * 0.6, false, fold);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ButterflyPainter extends CustomPainter {
  const ButterflyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;
    final sw = size.width * 0.3;

    // Upper wings
    final paint = Paint()..color = AppColors.cta.withValues(alpha: 0.75)..style = PaintingStyle.fill;
    canvas.drawPath(Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - sw * 0.05, cy - sw * 0.9, cx - sw * 1.1, cy - sw * 0.6, cx - sw * 0.8, cy + sw * 0.1)
      ..cubicTo(cx - sw * 0.6, cy + sw * 0.3, cx - sw * 0.15, cy + sw * 0.1, cx, cy)..close(), paint);
    canvas.drawPath(Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + sw * 0.05, cy - sw * 0.9, cx + sw * 1.1, cy - sw * 0.6, cx + sw * 0.8, cy + sw * 0.1)
      ..cubicTo(cx + sw * 0.6, cy + sw * 0.3, cx + sw * 0.15, cy + sw * 0.1, cx, cy)..close(), paint);

    // Lower wings
    paint.color = AppColors.primary.withValues(alpha: 0.5);
    canvas.drawPath(Path()
      ..moveTo(cx - sw * 0.1, cy + sw * 0.05)
      ..cubicTo(cx - sw * 0.3, cy + sw * 0.1, cx - sw * 0.6, cy + sw * 0.5, cx - sw * 0.25, cy + sw * 0.6)
      ..cubicTo(cx - sw * 0.1, cy + sw * 0.65, cx, cy + sw * 0.1, cx - sw * 0.1, cy + sw * 0.05)..close(), paint);
    canvas.drawPath(Path()
      ..moveTo(cx + sw * 0.1, cy + sw * 0.05)
      ..cubicTo(cx + sw * 0.3, cy + sw * 0.1, cx + sw * 0.6, cy + sw * 0.5, cx + sw * 0.25, cy + sw * 0.6)
      ..cubicTo(cx + sw * 0.1, cy + sw * 0.65, cx, cy + sw * 0.1, cx + sw * 0.1, cy + sw * 0.05)..close(), paint);

    // Body
    final body = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(cx, cy + sw * 0.6)..lineTo(cx, cy - sw * 0.1), body);

    // Antennae
    final ant = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 1.2..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(cx, cy - sw * 0.1)..cubicTo(cx - sw * 0.15, cy - sw * 0.3, cx - sw * 0.25, cy - sw * 0.45, cx - sw * 0.3, cy - sw * 0.5), ant);
    canvas.drawPath(Path()..moveTo(cx, cy - sw * 0.1)..cubicTo(cx + sw * 0.15, cy - sw * 0.3, cx + sw * 0.25, cy - sw * 0.45, cx + sw * 0.3, cy - sw * 0.5), ant);

    // Wing veins
    final vein = Paint()..color = AppColors.textPrimary.withValues(alpha: 0.08)..style = PaintingStyle.stroke..strokeWidth = 0.8;
    for (final a in [0.2, 0.4, 0.6]) {
      canvas.drawLine(Offset(cx, cy), Offset(cx - sw * 0.7 * a, cy - sw * 0.7 * (1 - a)), vein);
      canvas.drawLine(Offset(cx, cy), Offset(cx + sw * 0.7 * a, cy - sw * 0.7 * (1 - a)), vein);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
