// lib/features/auth/views/register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_strings.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/data/dummy/dummy_data.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final Set<String> _selectedInterests = {};
  int _step = 0; // 0: form, 1: interests

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  Future<void> _register() async {
    if (_selectedInterests.length < 2) {
      context.showErrorSnack('Pilih minimal 2 minat');
      return;
    }
    final vm = context.read<AuthViewModel>();
    final success = await vm.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _selectedInterests.toList(),
    );
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      context.showErrorSnack(vm.errorMessage ?? 'Registrasi gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: _step == 0 ? _buildForm() : _buildInterests(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(height: 12),
          Text('Buat Akun\nBarumu 🚀', style: AppTypography.displaySmall),
          const SizedBox(height: 8),
          Text('Daftar gratis dan mulai jelajahi ribuan event',
              style: AppTypography.bodyMedium),
          const SizedBox(height: 32),
          AppTextField(
            label: AppStrings.fullName,
            hint: AppStrings.fullNameHint,
            controller: _nameCtrl,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
              if (v.trim().length < 3) return 'Minimal 3 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            controller: _emailCtrl,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email wajib diisi';
              if (!v.isValidEmail) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: AppStrings.password,
            hint: AppStrings.passwordHint,
            controller: _passwordCtrl,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password wajib diisi';
              if (v.length < 8) return 'Minimal 8 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: AppStrings.confirmPassword,
            hint: AppStrings.confirmPasswordHint,
            controller: _confirmCtrl,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v != _passwordCtrl.text) return 'Password tidak cocok';
              return null;
            },
          ),
          const SizedBox(height: 28),
          AppPrimaryButton(
            label: 'Lanjutkan',
            onTap: _nextStep,
            icon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.alreadyHaveAccount,
                    style: AppTypography.bodyMedium),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    AppStrings.loginNow,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        IconButton(
          onPressed: () => setState(() => _step = 0),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 12),
        Text('Apa Minatmu? 🎯', style: AppTypography.displaySmall),
        const SizedBox(height: 8),
        Text(AppStrings.selectInterestsDesc, style: AppTypography.bodyMedium),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: DummyData.interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest.id);
                  } else {
                    _selectedInterests.add(interest.id);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(interest.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      interest.name,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedInterests.length} terpilih (min. 2)',
          style: AppTypography.caption.copyWith(
            color: _selectedInterests.length >= 2
                ? AppColors.success
                : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 32),
        Consumer<AuthViewModel>(
          builder: (context, vm, _) => AppPrimaryButton(
            label: AppStrings.registerNow,
            onTap: _register,
            isLoading: vm.isLoading,
            icon: Icons.check_rounded,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
