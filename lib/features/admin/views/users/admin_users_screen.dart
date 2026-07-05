// lib/features/admin/views/users/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/user_model.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAdminData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<AdminViewModel>().filterUsers(_selectedRole, _searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppTextField(
                label: '',
                hint: 'Cari nama atau email...',
                controller: _searchCtrl,
                prefixIcon: Icons.search_rounded,
              ),
            ),
            const SizedBox(height: 12),

            // Role Filtering Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _selectedRole == null,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedRole = null);
                        context.read<AdminViewModel>().filterUsers(null, _searchCtrl.text);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Peserta'),
                    selected: _selectedRole == UserRole.participant,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedRole = UserRole.participant);
                        context.read<AdminViewModel>().filterUsers(UserRole.participant, _searchCtrl.text);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Penyelenggara'),
                    selected: _selectedRole == UserRole.organizer,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedRole = UserRole.organizer);
                        context.read<AdminViewModel>().filterUsers(UserRole.organizer, _searchCtrl.text);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Admin'),
                    selected: _selectedRole == UserRole.admin,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedRole = UserRole.admin);
                        context.read<AdminViewModel>().filterUsers(UserRole.admin, _searchCtrl.text);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Users List
            Expanded(
              child: Consumer<AdminViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.users.isEmpty) {
                    return const Center(child: Text('Pengguna tidak ditemukan'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.users.length,
                    itemBuilder: (context, index) {
                      final u = vm.users[index];
                      final isSuspended = u.bio == 'SUSPENDED';

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
                            CircleAvatar(
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(u.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(u.name, style: AppTypography.labelLarge),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: u.role == UserRole.admin
                                              ? AppColors.errorLight
                                              : u.role == UserRole.organizer
                                                  ? AppColors.successLight
                                                  : AppColors.primaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          u.role.name.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: u.role == UserRole.admin
                                                  ? AppColors.error
                                                  : u.role == UserRole.organizer
                                                      ? AppColors.success
                                                      : AppColors.primary),
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(u.email, style: AppTypography.caption),
                                  if (isSuspended)
                                    Text(
                                      'SUSPENDED',
                                      style: AppTypography.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              itemBuilder: (context) => [
                                PopupMenuItem(value: 'detail', child: const Text('Detail')),
                                PopupMenuItem(
                                  value: 'suspend',
                                  child: Text(isSuspended ? 'Aktifkan Kembali' : 'Suspend Account'),
                                ),
                              ],
                              onSelected: (val) {
                                if (val == 'detail') {
                                  _showUserDetailModal(context, u);
                                } else if (val == 'suspend') {
                                  vm.suspendUser(u.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Status pengguna berhasil diubah.')),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showUserDetailModal(BuildContext context, UserModel u) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(u.name, style: AppTypography.headlineLarge),
              const SizedBox(height: 8),
              Text('Email: ${u.email}', style: AppTypography.bodyMedium),
              Text('Role: ${u.role.name.toUpperCase()}', style: AppTypography.bodyMedium),
              Text('Terdaftar: ${u.joinedAt.toString().substring(0, 10)}', style: AppTypography.bodyMedium),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Tutup',
                  onTap: () => Navigator.pop(context),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
