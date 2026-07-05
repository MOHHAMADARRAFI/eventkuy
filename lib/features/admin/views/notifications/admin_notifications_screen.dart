// lib/features/admin/views/notifications/admin_notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _targetAudience = 'Semua';

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendBroadcast() {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<AdminViewModel>().sendBroadcast(
      _targetAudience,
      _subjectCtrl.text.trim(),
      _msgCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi broadcast berhasil dikirim!'), backgroundColor: AppColors.success),
    );

    _subjectCtrl.clear();
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
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
                Text('Kirim Notifikasi Massal', style: AppTypography.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Kirimkan notifikasi push secara real-time ke grup pengguna tertentu di platform.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _targetAudience,
                  decoration: const InputDecoration(labelText: 'Target Audiens'),
                  items: const [
                    DropdownMenuItem(value: 'Semua', child: Text('Semua Pengguna')),
                    DropdownMenuItem(value: 'Participant', child: Text('Peserta Sahaja')),
                    DropdownMenuItem(value: 'Organizer', child: Text('Penyelenggara Sahaja')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _targetAudience = val);
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Subjek Pengumuman',
                  hint: 'Masukkan subjek',
                  controller: _subjectCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Subjek wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Isi Pesan Notifikasi',
                  hint: 'Tulis pesan pengumuman lengkap...',
                  controller: _msgCtrl,
                  maxLines: 5,
                  validator: (v) => v == null || v.isEmpty ? 'Pesan wajib diisi' : null,
                ),
                const SizedBox(height: 32),

                AppPrimaryButton(
                  label: 'Kirim Notifikasi',
                  onTap: _sendBroadcast,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
