import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── MINIMAP PAINTER ─────────────────────────────────────────────────────────
class MinimapPainter extends CustomPainter {
  final String pickup;
  final String dropoff;

  MinimapPainter({required this.pickup, required this.dropoff});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    // 1. Draw light map grid in background
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5;
    const gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw mock secondary roads in light gray
    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final roadPath1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.3);
    final roadPath2 = Path()
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.4, size.height);
    final roadPath3 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.8, size.width, size.height * 0.65);
    canvas.drawPath(roadPath1, secondaryRoadPaint);
    canvas.drawPath(roadPath2, secondaryRoadPaint);
    canvas.drawPath(roadPath3, secondaryRoadPaint);

    // 3. Draw primary route path in blue/green
    final routePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // We will draw a nice s-curve route between start and end
    final startOffset = Offset(size.width * 0.25, size.height * 0.75);
    final endOffset = Offset(size.width * 0.75, size.height * 0.25);
    final routePath = Path()
      ..moveTo(startOffset.dx, startOffset.dy)
      ..cubicTo(
        size.width * 0.2, size.height * 0.4,
        size.width * 0.8, size.height * 0.6,
        endOffset.dx, endOffset.dy,
      );
    
    canvas.drawPath(routePath, routePaint);

    // 4. Draw start pin (Green)
    final startPinPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(startOffset, 7, startPinPaint);
    canvas.drawCircle(startOffset, 3, Paint()..color = Colors.white);

    // 5. Draw end pin (Red)
    final endPinPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(endOffset, 7, endPinPaint);
    canvas.drawCircle(endOffset, 3, Paint()..color = Colors.white);

    // 6. Label Chennai landmark labels on the map
    _drawText(canvas, Offset(size.width * 0.05, size.height * 0.82), 'Pickup: $pickup', Colors.green[700]!, 7);
    _drawText(canvas, Offset(size.width * 0.52, size.height * 0.16), 'Drop: $dropoff', Colors.red[700]!, 7);
  }

  void _drawText(Canvas canvas, Offset offset, String text, Color color, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── APPROVED BAND PAINTER ──────────────────────────────────────────────────
class ApprovedBandPainter extends CustomPainter {
  final double minVal;
  final double maxVal;
  final double currentVal;

  ApprovedBandPainter({required this.minVal, required this.maxVal, required this.currentVal});

  @override
  void paint(Canvas canvas, Size size) {
    final yCenter = size.height / 2;
    
    // 1. Draw background track
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawLine(Offset(10, yCenter), Offset(size.width - 10, yCenter), trackPaint);

    // 2. Draw gradient within-band segment
    // Let's assume the green band is in the middle 70% of the range
    final bandStart = 10.0 + (size.width - 20) * 0.15;
    final bandEnd = 10.0 + (size.width - 20) * 0.85;
    final bandPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawLine(Offset(bandStart, yCenter), Offset(bandEnd, yCenter), bandPaint);

    // 3. Draw current fare indicator
    // Calculate current position relative to min/max
    double pct = 0.5; // default center
    if (maxVal > minVal) {
      pct = ((currentVal - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
    }
    final currentX = 10.0 + (size.width - 20) * pct;

    // Draw active pin cursor
    final cursorPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(currentX, yCenter), 8, cursorPaint);
    canvas.drawCircle(Offset(currentX, yCenter), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── DONUT CHART PAINTER ────────────────────────────────────────────────────
class DonutChartPainter extends CustomPainter {
  final double pctKeep; // e.g. 0.82
  final Color activeColor;

  DonutChartPainter({required this.pctKeep, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.25;

    final basePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, basePaint);

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * pctKeep;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── RADIAL GAUGE PAINTER ───────────────────────────────────────────────────
class RadialGaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0 (e.g. 0.987)

  RadialGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.16;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFEF4444) // Shows red for violation
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    final progressPaint = Paint()
      ..color = const Color(0xFF10B981) // Green for compliance
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── BAR CHART PAINTER ──────────────────────────────────────────────────────
class BarChartPainter extends CustomPainter {
  final List<double> values; // heights between 0 and 1.0

  BarChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = values.length;
    final spacing = size.width * 0.08;
    final totalSpacing = spacing * (barCount + 1);
    final barWidth = (size.width - totalSpacing) / barCount;

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFF0D9488), // Teal primary
          Color(0xFF2DD4BF),
        ],
      ).createShader(Offset.zero & size);

    for (int i = 0; i < barCount; i++) {
      final x = spacing + i * (barWidth + spacing);
      final h = values[i] * size.height * 0.85; // cap height
      final y = size.height - h;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── SURGE GRAPHIC PAINTER ──────────────────────────────────────────────────
class SurgeGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background city silhouette
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.85)
      ..lineTo(size.width * 0.08, size.height * 0.85)
      ..lineTo(size.width * 0.08, size.height * 0.75)
      ..lineTo(size.width * 0.15, size.height * 0.75)
      ..lineTo(size.width * 0.15, size.height * 0.9)
      ..lineTo(size.width * 0.22, size.height * 0.9)
      ..lineTo(size.width * 0.22, size.height * 0.65)
      ..lineTo(size.width * 0.3, size.height * 0.65)
      ..lineTo(size.width * 0.3, size.height * 0.8)
      ..lineTo(size.width * 0.35, size.height * 0.8)
      ..lineTo(size.width * 0.35, size.height * 0.92)
      ..lineTo(size.width * 0.45, size.height * 0.92)
      ..lineTo(size.width * 0.45, size.height * 0.72)
      ..lineTo(size.width * 0.52, size.height * 0.72)
      ..lineTo(size.width * 0.52, size.height * 0.88)
      ..lineTo(size.width * 0.6, size.height * 0.88)
      ..lineTo(size.width * 0.6, size.height * 0.58)
      ..lineTo(size.width * 0.7, size.height * 0.58)
      ..lineTo(size.width * 0.7, size.height * 0.82)
      ..lineTo(size.width * 0.78, size.height * 0.82)
      ..lineTo(size.width * 0.78, size.height * 0.7)
      ..lineTo(size.width * 0.88, size.height * 0.7)
      ..lineTo(size.width * 0.88, size.height * 0.85)
      ..lineTo(size.width, size.height * 0.85)
      ..lineTo(size.width, size.height)
      ..close();

    final paint = Paint()
      ..color = const Color(0xFFF1F5F9) // slate-100 silhoutte
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);

    // Draw secondary lighter silhoutte
    final path2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.92)
      ..lineTo(size.width * 0.12, size.height * 0.92)
      ..lineTo(size.width * 0.12, size.height * 0.82)
      ..lineTo(size.width * 0.28, size.height * 0.82)
      ..lineTo(size.width * 0.28, size.height * 0.75)
      ..lineTo(size.width * 0.42, size.height * 0.75)
      ..lineTo(size.width * 0.42, size.height * 0.9)
      ..lineTo(size.width * 0.58, size.height * 0.9)
      ..lineTo(size.width * 0.58, size.height * 0.8)
      ..lineTo(size.width * 0.72, size.height * 0.8)
      ..lineTo(size.width * 0.72, size.height * 0.88)
      ..lineTo(size.width * 0.85, size.height * 0.88)
      ..lineTo(size.width * 0.85, size.height * 0.78)
      ..lineTo(size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..close();

    final paint2 = Paint()
      ..color = const Color(0xFFE2E8F0) // slate-200 silhoutte
      ..style = PaintingStyle.fill;

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RegulatorMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    // 1. Draw light map grid in background
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 0.5;
    const gridSize = 15.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw mock secondary roads in very light gray
    final roadPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final road1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.45);
    final road2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.5, size.height);
    final road3 = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.75);
    final road4 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(size.width * 0.3, size.height * 0.5, size.width * 0.7, size.height * 0.5, size.width * 0.8, size.height);

    canvas.drawPath(road1, roadPaint);
    canvas.drawPath(road2, roadPaint);
    canvas.drawPath(road3, roadPaint);
    canvas.drawPath(road4, roadPaint);

    // 3. Draw compliance polygon (light blue shaded area)
    final polyPaint = Paint()
      ..color = const Color(0xFFE0F2FE).withOpacity(0.6) // light blue fill
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8) // light blue border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final polyPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.3)
      ..lineTo(size.width * 0.75, size.height * 0.2)
      ..lineTo(size.width * 0.85, size.height * 0.7)
      ..lineTo(size.width * 0.6, size.height * 0.85)
      ..lineTo(size.width * 0.15, size.height * 0.65)
      ..close();

    canvas.drawPath(polyPath, polyPaint);
    canvas.drawPath(polyPath, borderPaint);

    // 4. Draw text "Chennai" in the center
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Chennai',
        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.5 - textPainter.height / 2));

    // 5. Draw live trip dots (green for complied, red for anomaly)
    final greenDot = Paint()..color = const Color(0xFF10B981);
    final redDot = Paint()..color = const Color(0xFFEF4444);

    final points = [
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.45, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.3),
      Offset(size.width * 0.55, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.55),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.25, size.height * 0.6),
    ];

    for (int i = 0; i < points.length; i++) {
      final color = i == 2 ? const Color(0xFFEF4444) : const Color(0xFF10B981);
      final dotPaint = i == 2 ? redDot : greenDot;

      canvas.drawCircle(points[i], 4, dotPaint);
      canvas.drawCircle(points[i], 1.5, Paint()..color = Colors.white);
      
      canvas.drawCircle(
        points[i],
        8,
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SkylinePainter extends CustomPainter {
  final Color color;

  SkylinePainter({this.color = const Color(0xFFE2E8F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.95)
      ..lineTo(size.width * 0.04, size.height * 0.95)
      ..lineTo(size.width * 0.04, size.height * 0.75)
      ..lineTo(size.width * 0.08, size.height * 0.75)
      ..lineTo(size.width * 0.08, size.height * 0.95)
      ..lineTo(size.width * 0.12, size.height * 0.95)
      ..lineTo(size.width * 0.12, size.height * 0.6)
      ..lineTo(size.width * 0.17, size.height * 0.6)
      ..lineTo(size.width * 0.17, size.height * 0.9)
      ..lineTo(size.width * 0.23, size.height * 0.9)
      ..lineTo(size.width * 0.23, size.height * 0.55)
      ..lineTo(size.width * 0.25, size.height * 0.45)
      ..lineTo(size.width * 0.27, size.height * 0.45)
      ..lineTo(size.width * 0.29, size.height * 0.55)
      ..lineTo(size.width * 0.29, size.height * 0.9)
      ..lineTo(size.width * 0.33, size.height * 0.9)
      ..lineTo(size.width * 0.33, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.92)
      ..lineTo(size.width * 0.44, size.height * 0.92)
      ..lineTo(size.width * 0.44, size.height * 0.63)
      ..lineTo(size.width * 0.49, size.height * 0.63)
      ..lineTo(size.width * 0.49, size.height * 0.9)
      ..lineTo(size.width * 0.53, size.height * 0.9)
      ..lineTo(size.width * 0.53, size.height * 0.68)
      ..lineTo(size.width * 0.54, size.height * 0.68)
      ..arcToPoint(
        Offset(size.width * 0.62, size.height * 0.68),
        radius: Radius.circular(size.width * 0.04),
        clockwise: true,
      )
      ..lineTo(size.width * 0.62, size.height * 0.9)
      ..lineTo(size.width * 0.67, size.height * 0.9)
      ..lineTo(size.width * 0.67, size.height * 0.35)
      ..lineTo(size.width * 0.69, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.9)
      ..lineTo(size.width * 0.75, size.height * 0.9)
      ..lineTo(size.width * 0.75, size.height * 0.65)
      ..lineTo(size.width * 0.83, size.height * 0.65)
      ..lineTo(size.width * 0.83, size.height * 0.88)
      ..lineTo(size.width, size.height * 0.88)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
