// lib/features/organizer/views/analytics/organizer_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';

class OrganizerAnalyticsScreen extends StatelessWidget {
  const OrganizerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Analitik Penyelenggara', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ringkasan Pendapatan', style: AppTypography.headlineMedium),
              const SizedBox(height: 12),
              
              // Revenue chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pendapatan Bersih', style: AppTypography.caption),
                    Text(currencyFormat.format(3450000), style: AppTypography.displaySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: MiniAreaChartPainter(
                          data: [100000, 250000, 150000, 600000, 450000, 1200000, 1000000],
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category popularity & Tickets summary
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 28),
                          const SizedBox(height: 12),
                          Text('Event Terpopuler', style: AppTypography.caption),
                          Text('Flutter Bootcamp', style: AppTypography.labelLarge),
                          Text('245 Tiket Terjual', style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.pie_chart_rounded, color: AppColors.primary, size: 28),
                          const SizedBox(height: 12),
                          Text('Kategori Utama', style: AppTypography.caption),
                          Text('Teknologi', style: AppTypography.labelLarge),
                          Text('85% Total Event', style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('Distribusi Tiket Terjual', style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildDistItem('Early Bird (Diskon)', '76 Tiket', 0.45, Colors.blue),
                    _buildDistItem('Regular Standard', '155 Tiket', 0.85, Colors.green),
                    _buildDistItem('VIP Exclusive', '45 Tiket', 0.25, Colors.purple),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistItem(String label, String value, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.bodyMedium),
              Text(value, style: AppTypography.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          )
        ],
      ),
    );
  }
}

// Mini Area Painter for Revenue Line Graph representation
class MiniAreaChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool isDark;

  MiniAreaChartPainter({
    required this.data,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()..style = PaintingStyle.fill;

    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1;

    final double stepX = size.width / (data.length - 1);
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (data[i] / maxVal) * (size.height - 20) - 10;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      path.cubicTo(
        prev.dx + stepX / 2, prev.dy,
        current.dx - stepX / 2, current.dy,
        current.dx, current.dy,
      );
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      fillPath.cubicTo(
        prev.dx + stepX / 2, prev.dy,
        current.dx - stepX / 2, current.dy,
        current.dx, current.dy,
      );
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
    );
    paintFill.shader = gradient.createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw circles at data points
    final circlePaint = Paint()..color = color..style = PaintingStyle.fill;
    for (var p in points) {
      canvas.drawCircle(p, 4, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MiniAreaChartPainter oldDelegate) => false;
}
