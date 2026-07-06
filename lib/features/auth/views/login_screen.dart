// lib/features/auth/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/data/models/user_model.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi loading
    await Future.delayed(const Duration(milliseconds: 800));

    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (!mounted) return;
    setState(() => _isLoading = false);

    // ── Akun Dummy Hardcoded ──────────────────────────────
    // 1. ADMIN
    if (email == 'admin@eventkuy.com' && password == 'password') {
      context.read<AuthViewModel>().loginWithDummyUser(
        UserModel(
          id: 'admin_001',
          name: 'Admin EventKuy',
          email: 'admin@eventkuy.com',
          interests: [],
          joinedAt: DateTime(2023, 1, 1),
          totalRegistrations: 0,
          totalBookmarks: 0,
          role: UserRole.admin,
          organizationName: 'EventKuy Platform',
        ),
      );
      context.go('/admin/dashboard');
      return;
    }

    // 2. EVENT ORGANIZER (EO)
    if (email == 'eo@eventkuy.com' && password == 'password') {
      context.read<AuthViewModel>().loginWithDummyUser(
        UserModel(
          id: 'org_001',
          name: 'Event Organizer',
          email: 'eo@eventkuy.com',
          interests: [],
          joinedAt: DateTime(2023, 6, 1),
          totalRegistrations: 0,
          totalBookmarks: 0,
          role: UserRole.organizer,
          organizationName: 'EO Kreatif Indonesia',
        ),
      );
      context.go('/organizer/dashboard');
      return;
    }

    // 3. Peserta biasa (semua email lain)
    if (password.length >= 6) {
      context.read<AuthViewModel>().loginWithDummyUser(
        UserModel(
          id: 'user_${email.hashCode.abs()}',
          name: email.split('@').first,
          email: email,
          interests: [],
          joinedAt: DateTime.now(),
          totalRegistrations: 0,
          totalBookmarks: 0,
          role: UserRole.participant,
        ),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email atau Password salah.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF4F6FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Banner Indigo ───────────────────────
            Container(
              width: double.infinity,
              height: size.height * 0.32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo, Color(0xFF3F51B5), Color(0xFF7986CB)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EventKuy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Temukan & Nikmati Event Terbaik',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form Card ─────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk ke Akun Anda',
                          style: AppTypography.displaySmall.copyWith(
                            color: isDark ? Colors.white : const Color(0xFF1A237E),
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Gunakan email dan password untuk login',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Email Field ──────────────────
                        _buildLabel('Email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: _inputDecoration(
                            hint: 'Contoh: user@email.com',
                            icon: Icons.email_outlined,
                            isDark: isDark,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email wajib diisi';
                            if (!v.trim().isValidEmail) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── Password Field ───────────────
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: _inputDecoration(
                            hint: 'Masukkan password Anda',
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.indigo,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password wajib diisi';
                            if (v.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),

                        // ── Forgot Password ──────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Login Button ─────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Colors.indigo.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Divider ──────────────────────
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'atau',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Info Akun Demo ───────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, color: Colors.indigo, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Akun Demo Tersedia',
                                    style: TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildDemoAccount(
                                Icons.admin_panel_settings_outlined,
                                'Admin',
                                'admin@eventkuy.com',
                                'password',
                              ),
                              const SizedBox(height: 6),
                              _buildDemoAccount(
                                Icons.business_center_outlined,
                                'Event Organizer',
                                'eo@eventkuy.com',
                                'password',
                              ),
                              const SizedBox(height: 6),
                              _buildDemoAccount(
                                Icons.person_outline_rounded,
                                'Peserta',
                                'Email apa saja',
                                'min. 6 karakter',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Register Link ─────────────────
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF1A237E),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.indigo, size: 20),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildDemoAccount(IconData icon, String role, String email, String pass) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade300, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$role: ',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo.shade700),
                ),
                TextSpan(text: '$email / $pass', style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
