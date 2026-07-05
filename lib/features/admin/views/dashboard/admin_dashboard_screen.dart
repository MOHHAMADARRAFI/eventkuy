// lib/features/admin/views/dashboard/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';
import 'package:eventkuy/data/models/user_model.dart';
import 'package:eventkuy/data/models/event_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAdminData();
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
          onRefresh: () => context.read<AdminViewModel>().loadAdminData(),
          child: Consumer<AdminViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Pre-calculate stats
              final pendingOrgs = vm.users.where((u) => u.verificationStatus == VerificationStatus.pending).length;
              final pendingEvts = vm.allEvents.where((e) => e.status == EventStatus.submittedForReview).length;
              final activeUsers = vm.users.length;
              final totalOrgs = vm.organizers.length;
              final totalEvents = vm.allEvents.length;
              final pendingComplaints = vm.complaints.where((c) => c['status'] == 'Review').length;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Header Greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dashboard Admin 🛡️', style: AppTypography.displaySmall),
                            Text('Pantau dan kelola seluruh sistem EventKuy', style: AppTypography.caption),
                          ],
                        ),
                        // Log switcher trigger back to Participant if in debug
                        CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Urgent Approvals Queue Row
                    Text('Antrean Urgent', style: AppTypography.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQueueCard(
                            title: 'Persetujuan Org.',
                            count: '$pendingOrgs',
                            color: AppColors.warning,
                            icon: Icons.business_center_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQueueCard(
                            title: 'Review Event',
                            count: '$pendingEvts',
                            color: AppColors.primary,
                            icon: Icons.rate_review_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQueueCard(
                            title: 'Laporan Masuk',
                            count: '$pendingComplaints',
                            color: AppColors.error,
                            icon: Icons.report_problem_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Financial metrics & Growth
                    Text('Metrik Keuangan', style: AppTypography.titleLarge),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pendapatan Bulanan:', style: AppTypography.caption),
                              Text(currencyFormat.format(23500000), style: AppTypography.labelLarge.copyWith(color: AppColors.success)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pertumbuhan Bulanan:', style: AppTypography.caption),
                              Text('+14.2%', style: AppTypography.labelLarge.copyWith(color: AppColors.success)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Platform overview statistics
                    Text('Statistik Platform', style: AppTypography.titleLarge),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildPlatformStatCard('Total User', '$activeUsers', Icons.people_rounded, isDark),
                        _buildPlatformStatCard('Total Organizer', '$totalOrgs', Icons.business_rounded, isDark),
                        _buildPlatformStatCard('Total Event', '$totalEvents', Icons.event_rounded, isDark),
                        _buildPlatformStatCard('Kategori Event', '${vm.categories.length}', Icons.category_rounded, isDark),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // User growth visual representation
                    Text('Analitik Pertumbuhan User', style: AppTypography.titleLarge),
                    const SizedBox(height: 12),
                    Container(
                      height: 180,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                      ),
                      child: CustomPaint(
                        painter: UserGrowthPainter(
                          points: [20, 32, 45, 60, 89, 120, 150],
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQueueCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(count, style: AppTypography.headlineSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlatformStatCard(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.caption),
              Icon(icon, color: AppColors.primary, size: 18),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}

// Painter representing Platform User growth lines
class UserGrowthPainter extends CustomPainter {
  final List<double> points;
  final bool isDark;

  UserGrowthPainter({required this.points, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintCircle = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12
      ..strokeWidth = 1;

    double maxVal = points.reduce((a, b) => a > b ? a : b);
    final double stepX = size.width / (points.length - 1);
    final List<Offset> offsets = [];

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (points[i] / maxVal) * (size.height - 30) - 15;
      offsets.add(Offset(x, y));
    }

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }

    canvas.drawPath(path, paintLine);

    for (var p in offsets) {
      canvas.drawLine(Offset(p.dx, 0), Offset(p.dx, size.height), gridPaint);
      canvas.drawCircle(p, 4, paintCircle);
    }
  }

  @override
  bool shouldRepaint(covariant UserGrowthPainter oldDelegate) => false;
}
