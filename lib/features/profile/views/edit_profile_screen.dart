// lib/features/profile/views/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _locationCtrl = TextEditingController(text: user?.location ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final authVm = context.read<AuthViewModel>();
    final user = authVm.currentUser;
    if (user == null) return;

    final updated = user.copyWith(
      name: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );
    await authVm.updateProfile(updated);
    if (!mounted) return;
    context.showSuccessSnack('Profil berhasil diperbarui!');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profil', style: AppTypography.titleLarge),
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Consumer<AuthViewModel>(
                      builder: (_, vm, __) => CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          vm.currentUser?.name.isNotEmpty == true
                              ? vm.currentUser!.name[0].toUpperCase()
                              : 'U',
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Ubah Foto Profil',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    )),
              ),
              const SizedBox(height: AppDimensions.xxl),

              // Fields
              AppTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkapmu',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                  if (v.trim().length < 2) return 'Minimal 2 karakter';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.lg),
              AppTextField(
                label: 'Bio',
                hint: 'Ceritakan sedikit tentang dirimu...',
                controller: _bioCtrl,
                prefixIcon: Icons.info_outline_rounded,
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.lg),
              AppTextField(
                label: 'Lokasi',
                hint: 'Kota, Provinsi',
                controller: _locationCtrl,
                prefixIcon: Icons.location_on_outlined,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppDimensions.xxxl),

              Consumer<AuthViewModel>(
                builder: (_, vm, __) => AppPrimaryButton(
                  label: 'Simpan Perubahan',
                  onTap: _save,
                  isLoading: vm.isLoading,
                  icon: Icons.check_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
