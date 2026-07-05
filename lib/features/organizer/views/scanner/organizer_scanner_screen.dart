// lib/features/organizer/views/scanner/organizer_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';

class OrganizerScannerScreen extends StatefulWidget {
  const OrganizerScannerScreen({super.key});

  @override
  State<OrganizerScannerScreen> createState() => _OrganizerScannerScreenState();
}

class _OrganizerScannerScreenState extends State<OrganizerScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scanPosition;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanPosition = Tween<double>(begin: 0.0, end: 1.0).animate(_animCtrl);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleScanResult(String type) {
    // Shows custom Material 3 dialog with the scan result feedback
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Color mainColor;
        IconData icon;
        String title;
        String desc;
        
        if (type == 'valid') {
          mainColor = AppColors.success;
          icon = Icons.check_circle_rounded;
          title = 'Tiket Valid!';
          desc = 'Nama: Ahmad Fauzi\nTiket: VIP Exclusive\nCheck-in Berhasil.';
        } else if (type == 'already') {
          mainColor = AppColors.warning;
          icon = Icons.warning_rounded;
          title = 'Sudah Check-In!';
          desc = 'Nama: Jessica Mila\nTiket: Regular\nTelah check-in pada pukul 14:02.';
        } else {
          mainColor = AppColors.error;
          icon = Icons.cancel_rounded;
          title = 'Tiket Tidak Valid!';
          desc = 'Kode tiket tidak terdaftar atau transaksi pembayaran belum diselesaikan.';
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Icon(icon, color: mainColor, size: 64),
              const SizedBox(height: 12),
              Text(title, style: AppTypography.headlineMedium.copyWith(color: mainColor), textAlign: TextAlign.center),
            ],
          ),
          content: Text(desc, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
          actions: [
            Center(
              child: SizedBox(
                width: 140,
                child: AppPrimaryButton(
                  label: 'Selesai',
                  height: 40,
                  backgroundColor: mainColor,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black, // Dark background typical for camera scanners
      appBar: AppBar(
        title: const Text('Scan QR Tiket', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Mock camera viewfinder
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Container(color: Colors.black45),
                    // Animated scanning beam line
                    AnimatedBuilder(
                      animation: _scanPosition,
                      builder: (context, child) {
                        return Positioned(
                          top: _scanPosition.value * 250,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instructions text
          const Positioned(
            bottom: 220,
            left: 20,
            right: 20,
            child: Center(
              child: Text(
                'Posisikan QR Code tiket di dalam area kotak untuk memindai otomatis.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Simulator Panel for Development
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SIMULATOR SCANNER (DEVELOPMENT MODE)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleScanResult('valid'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.success),
                          ),
                          child: const Text('Valid', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleScanResult('already'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(color: AppColors.warning),
                          ),
                          child: const Text('Already', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleScanResult('invalid'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Invalid', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
