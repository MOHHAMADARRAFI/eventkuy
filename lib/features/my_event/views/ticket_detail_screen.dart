import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/data/models/registration_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TicketDetailScreen extends StatelessWidget {
  final RegistrationModel registration;

  const TicketDetailScreen({super.key, required this.registration});

  @override
  Widget build(BuildContext context) {
    final event = registration.event;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('E-Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Container Tiket Utama
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bagian Gambar Event
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: CachedNetworkImage(
                      imageUrl: event.posterUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  
                  // Bagian Info Event
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoRow(Icons.calendar_today_rounded, event.startDate.formattedDate),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.access_time_rounded, event.startDate.formattedTime),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.location_on_rounded, event.location),
                      ],
                    ),
                  ),
                  
                  // Garis Pemisah Tiket (Dash Line)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: List.generate(
                            (constraints.constrainWidth() / 10).floor(),
                            (index) => SizedBox(
                              width: 5,
                              height: 1.5,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Bagian QR Code & Kode Tiket
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Scan QR Code saat masuk area event',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 150,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          registration.ticketCode ?? 'TICKET-${registration.id.substring(0, 8).toUpperCase()}',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: registration.status.bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            registration.status.label,
                            style: TextStyle(
                              color: registration.status.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Tombol Unduh
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.showSnack('Tiket berhasil diunduh ke galeri!');
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Unduh Tiket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// Extension bantuan untuk warna status
extension RegistrationStatusColorExt on RegistrationStatus {
  Color get color {
    switch (this) {
      case RegistrationStatus.upcoming: return AppColors.primary;
      case RegistrationStatus.completed: return AppColors.success;
      case RegistrationStatus.cancelled: return AppColors.error;
      case RegistrationStatus.pending: return AppColors.warning;
    }
  }

  Color get bgColor {
    switch (this) {
      case RegistrationStatus.upcoming: return AppColors.primaryContainer;
      case RegistrationStatus.completed: return AppColors.successLight;
      case RegistrationStatus.cancelled: return AppColors.errorLight;
      case RegistrationStatus.pending: return AppColors.warningLight;
    }
  }
}
