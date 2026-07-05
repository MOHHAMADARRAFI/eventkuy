// lib/features/organizer/dashboard/organizer_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/data/models/payment_model.dart';
import 'package:eventkuy/features/organizer/dashboard/organizer_dashboard_viewmodel.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orgId = context.read<AuthViewModel>().currentUser?.id ?? 'org_001';
      context.read<OrganizerDashboardViewModel>().loadDashboardData(orgId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final orgId = context.read<AuthViewModel>().currentUser?.id ?? 'org_001';
            await context.read<OrganizerDashboardViewModel>().loadDashboardData(orgId);
          },
          child: Consumer<OrganizerDashboardViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH,
                  vertical: AppDimensions.screenPaddingV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Greeting
                    _buildHeader(context),
                    const SizedBox(height: 24),

                    // Quick Stats Grid
                    _buildStatsGrid(vm, currencyFormat, isDark),
                    const SizedBox(height: 24),

                    // Charts Section (Painter)
                    _buildChartsSection(isDark),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    // Recent transactions / registrations
                    _buildRecentTransactions(vm, currencyFormat, isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
          child: user?.photoUrl == null
              ? Text(user?.name[0].toUpperCase() ?? 'O', style: const TextStyle(fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, Penyelenggara! 👋', style: AppTypography.caption),
            Text(user?.organizationName ?? user?.name ?? 'Organizer', style: AppTypography.titleLarge),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notification'),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(OrganizerDashboardViewModel vm, NumberFormat format, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Event',
                value: '${vm.totalEvents}',
                icon: Icons.event_rounded,
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Event Aktif',
                value: '${vm.activeEvents}',
                icon: Icons.offline_pin_rounded,
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Peserta',
                value: '${vm.totalParticipants}',
                icon: Icons.people_rounded,
                color: AppColors.secondary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Pendapatan',
                value: format.format(vm.totalRevenue),
                icon: Icons.payments_rounded,
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detail Pembayaran', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSubStat('Menunggu', format.format(vm.pendingPayments), AppColors.warning),
                  _buildSubStat('Lunas', format.format(vm.totalRevenue), AppColors.success),
                  _buildSubStat('Refund', format.format(vm.refundsCount), AppColors.error),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSubStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.titleSmall.copyWith(color: color, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.caption),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tren Pendaftaran Peserta', style: AppTypography.titleLarge),
          Text('Statistik pendaftaran 7 hari terakhir', style: AppTypography.caption),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(
                data: [10, 25, 18, 42, 30, 60, 52],
                labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTypography.titleLarge),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(context, Icons.add_circle_outline_rounded, 'Buat Event', '/organizer/create-event'),
            _buildActionItem(context, Icons.qr_code_scanner_rounded, 'Scan Tiket', '/organizer/scanner'),
            _buildActionItem(context, Icons.people_outline_rounded, 'Peserta', '/organizer/participants'),
            _buildActionItem(context, Icons.analytics_outlined, 'Analitik', '/organizer/analytics'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(OrganizerDashboardViewModel vm, NumberFormat format, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pendaftaran Terbaru', style: AppTypography.titleLarge),
        const SizedBox(height: 12),
        if (vm.recentPayments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text('Belum ada transaksi pendaftaran', style: AppTypography.caption),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.recentPayments.length,
            itemBuilder: (context, index) {
              final pay = vm.recentPayments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pay.transactionNumber, style: AppTypography.labelMedium),
                          Text(pay.paymentMethod, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(format.format(pay.amount), style: AppTypography.labelMedium.copyWith(color: AppColors.success)),
                        Text(pay.paymentStatus.label,
                            style: AppTypography.caption.copyWith(
                                color: pay.paymentStatus == PaymentStatus.paid ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

// Custom line chart painter for premium, customizable dashboards
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final bool isDark;

  LineChartPainter({
    required this.data,
    required this.labels,
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

    final paintFill = Paint()
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1;

    final double stepX = size.width / (data.length - 1);
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (data[i] / maxVal) * (size.height - 30) - 20;
      points.add(Offset(x, y));
    }

    // Path for line
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Draw smooth Bezier curve
      final prev = points[i - 1];
      final current = points[i];
      final control1 = Offset(prev.dx + stepX / 2, prev.dy);
      final control2 = Offset(current.dx - stepX / 2, current.dy);
      path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, current.dx, current.dy);
    }

    // Path for gradient fill below line
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height - 20)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      final control1 = Offset(prev.dx + stepX / 2, prev.dy);
      final control2 = Offset(current.dx - stepX / 2, current.dy);
      fillPath.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, current.dx, current.dy);
    }
    fillPath.lineTo(points.last.dx, size.height - 20);
    fillPath.close();

    // Draw Fill Gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
    );
    paintFill.shader = gradient.createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, paintFill);

    // Draw Line
    canvas.drawPath(path, paintLine);

    // Draw grid lines & data values
    final gridPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12
      ..strokeWidth = 1;

    for (int i = 0; i < points.length; i++) {
      // Vertical grid
      canvas.drawLine(Offset(points[i].dx, 0), Offset(points[i].dx, size.height - 20), gridPaint);

      // Draw Labels
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white38 : Colors.black38,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(points[i].dx - textPainter.width / 2, size.height - 15));

      // Draw values on hover circles
      final circlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = isDark ? Colors.white : Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(points[i], 4, circlePaint);
      canvas.drawCircle(points[i], 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => false;
}
