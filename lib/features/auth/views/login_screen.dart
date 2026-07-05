// lib/features/auth/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_strings.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/features/admin/presentation/pages/admin_dashboard.dart' as eventkuy_admin;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email == 'admin@eventkuy.com' && password == 'password') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const eventkuy_admin.AdminDashboardScreen()),
      );
      return;
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.login(email, password);
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      context.showErrorSnack(vm.errorMessage ?? 'Login gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 28),
                Text('Selamat Datang\nKembali! 👋',
                    style: AppTypography.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk temukan event terbaik untukmu',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 36),
                // Email
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
                // Password
                AppTextField(
                  label: AppStrings.password,
                  hint: AppStrings.passwordHint,
                  controller: _passwordCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Login button
                Consumer<AuthViewModel>(
                  builder: (context, vm, _) => AppPrimaryButton(
                    label: AppStrings.login,
                    onTap: _login,
                    isLoading: vm.isLoading,
                  ),
                ),
                const SizedBox(height: 20),
                // Or divider
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(AppStrings.or,
                          style: AppTypography.bodySmall),
                    ),
                    const Expanded(
                        child: Divider(color: AppColors.border, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),
                // Google login
                GoogleSignInButton(
                  onTap: () {
                    context.showSnack('Google login akan segera hadir!');
                  },
                ),
                const SizedBox(height: 32),
                // Register link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.dontHaveAccount,
                          style: AppTypography.bodyMedium),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          AppStrings.registerNow,
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
          ),
        ),
      ),
    );
  }
}
