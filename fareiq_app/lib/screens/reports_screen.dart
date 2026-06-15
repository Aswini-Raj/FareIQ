import 'package:flutter/material.dart';
import 'app_layout.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      activeTab: 'Reports',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMPLIANCE & FARE REPORTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNavy,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aggregated historical compliance data and average travel pricing indexes.',
                style: TextStyle(fontSize: 12, color: kTextSec),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildReportMetricCard('Compliance Trend', '98.7% average', Icons.trending_up, kGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReportMetricCard('Total Audited', '124,532 trips', Icons.playlist_add_check_rounded, kNavy),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COMPLIANCE BY WEEK (PAST 6 WEEKS)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextSec),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _LineChartPainter(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text('Wk 21', style: TextStyle(fontSize: 10, color: kTextHint, fontWeight: FontWeight.bold)),
                        Text('Wk 22', style: TextStyle(fontSize: 10, color: kTextHint, fontWeight: FontWeight.bold)),
                        Text('Wk 23', style: TextStyle(fontSize: 10, color: kTextHint, fontWeight: FontWeight.bold)),
                        Text('Wk 24', style: TextStyle(fontSize: 10, color: kTextHint, fontWeight: FontWeight.bold)),
                        Text('Wk 25', style: TextStyle(fontSize: 10, color: kTextHint, fontWeight: FontWeight.bold)),
                        Text('Wk 26', style: TextStyle(fontSize: 10, color: kTextHint, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: kTextSec, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPri)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = kBorder
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal grids
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(size.width * 0.08, size.height * 0.5),
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.42, size.height * 0.45),
      Offset(size.width * 0.58, size.height * 0.2),
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.92, size.height * 0.1),
    ];

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Fill under line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          kGreen.withOpacity(0.35),
          kGreen.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = kGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()..color = kGreen;
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var p in points) {
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 5, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
