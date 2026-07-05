// lib/features/admin/views/settings/admin_activity_log_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/audit_log_model.dart';
import 'package:eventkuy/data/models/user_model.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';

class AdminActivityLogScreen extends StatefulWidget {
  const AdminActivityLogScreen({super.key});

  @override
  State<AdminActivityLogScreen> createState() => _AdminActivityLogScreenState();
}

class _AdminActivityLogScreenState extends State<AdminActivityLogScreen> {
  final _searchCtrl = TextEditingController();
  UserRole? _filterRole;

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
    // Perform simple local filtering in this component or trigger viewmodel action
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Audit Log Aktivitas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppTextField(
                label: '',
                hint: 'Cari log berdasarkan aksi, user, target...',
                controller: _searchCtrl,
                prefixIcon: Icons.search_rounded,
              ),
            ),
            const SizedBox(height: 12),

            // Role filtering
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _filterRole == null,
                    onSelected: (val) {
                      if (val) setState(() => _filterRole = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Peserta'),
                    selected: _filterRole == UserRole.participant,
                    onSelected: (val) {
                      if (val) setState(() => _filterRole = UserRole.participant);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Penyelenggara'),
                    selected: _filterRole == UserRole.organizer,
                    onSelected: (val) {
                      if (val) setState(() => _filterRole = UserRole.organizer);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Admin'),
                    selected: _filterRole == UserRole.admin,
                    onSelected: (val) {
                      if (val) setState(() => _filterRole = UserRole.admin);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logs stream
            Expanded(
              child: Consumer<AdminViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Perform local filter based on search control & role chips
                  final query = _searchCtrl.text.toLowerCase().trim();
                  var list = List<AuditLogModel>.from(vm.auditLogs);

                  if (_filterRole != null) {
                    list = list.where((l) => l.role == _filterRole).toList();
                  }

                  if (query.isNotEmpty) {
                    list = list.where((l) {
                      return l.userName.toLowerCase().contains(query) ||
                          l.action.toLowerCase().contains(query) ||
                          l.description.toLowerCase().contains(query) ||
                          l.target.toLowerCase().contains(query);
                    }).toList();
                  }

                  if (list.isEmpty) {
                    return const Center(child: Text('Log tidak ditemukan'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final log = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history_toggle_off_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(log.action.toUpperCase(), style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text(log.createdAt.toString().substring(0, 16), style: AppTypography.caption),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(log.description, style: AppTypography.bodyMedium),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('User: ${log.userName} (${log.role.name})', style: AppTypography.caption),
                                Text('${log.device} • ${log.ipAddress}', style: AppTypography.caption),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
