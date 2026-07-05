// lib/features/organizer/profile/apply_organizer_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/data/models/user_model.dart';

class ApplyOrganizerScreen extends StatefulWidget {
  const ApplyOrganizerScreen({super.key});

  @override
  State<ApplyOrganizerScreen> createState() => _ApplyOrganizerScreenState();
}

class _ApplyOrganizerScreenState extends State<ApplyOrganizerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankAccCtrl = TextEditingController();
  final _bankAccNameCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _logoUrl = 'https://picsum.photos/seed/org_logo/200/200';
  String? _docsUrl = 'https://eventkuy.id/docs/dummy_verification_doc.pdf';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccCtrl.dispose();
    _bankAccNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authVm = context.read<AuthViewModel>();
      final currentUser = authVm.currentUser;

      if (currentUser != null) {
        // Update user state to pending, saving organizational details
        final updatedUser = currentUser.copyWith(
          organizationName: _nameCtrl.text.trim(),
          organizationLogo: _logoUrl,
          verificationStatus: VerificationStatus.pending,
          verificationDocsUrl: _docsUrl,
          bankName: _bankNameCtrl.text.trim(),
          bankAccountNo: _bankAccCtrl.text.trim(),
          bankAccountName: _bankAccNameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
        );

        await authVm.updateProfile(updatedUser);
        if (mounted) {
          context.go('/organizer/verification-status');
        }
      }
    } catch (e) {
      debugPrint('Error applying as organizer: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Penyelenggara', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lengkapi Data Organisasi', style: AppTypography.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Daftarkan organisasimu agar bisa mulai membuat dan mempublikasikan event secara profesional.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Logo selector simulation
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: _logoUrl != null ? NetworkImage(_logoUrl!) : null,
                        child: _logoUrl == null
                            ? const Icon(Icons.business_rounded, size: 40, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Simulasi upload logo organisasi.')),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: 'Nama Organisasi / Komunitas',
                  hint: 'Masukkan nama organisasi',
                  controller: _nameCtrl,
                  prefixIcon: Icons.business_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Nama organisasi wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Email Resmi Organisasi',
                  hint: 'Masukkan email organisasi',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Email resmi wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nomor HP Kontak',
                  hint: 'Masukkan nomor HP',
                  controller: _phoneCtrl,
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Nomor HP wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                Text('Informasi Bank Penampung', style: AppTypography.titleLarge),
                const SizedBox(height: 8),
                Text('Digunakan untuk pencairan dana hasil penjualan tiket.', style: AppTypography.caption),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nama Bank',
                  hint: 'Contoh: Bank BCA, Bank Mandiri',
                  controller: _bankNameCtrl,
                  prefixIcon: Icons.account_balance_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Nama bank wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nomor Rekening',
                  hint: 'Masukkan nomor rekening bank',
                  controller: _bankAccCtrl,
                  prefixIcon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Nomor rekening wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nama Pemilik Rekening',
                  hint: 'Masukkan nama pemilik rekening',
                  controller: _bankAccNameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Nama pemilik rekening wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                // Documents upload simulation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description_rounded, color: AppColors.primary, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dokumen Legalitas / Identitas', style: AppTypography.labelLarge),
                            Text('Unggah KTP / Akta Organisasi (PDF)', style: AppTypography.caption),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Simulasi upload dokumen legalitas.')),
                          );
                        },
                        child: const Text('Upload'),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                AppPrimaryButton(
                  label: 'Ajukan Verifikasi',
                  onTap: _submitApplication,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
