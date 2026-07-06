// lib/features/admin/views/categories/admin_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/category_model.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditDialog(context, null),
          )
        ],
      ),
      body: SafeArea(
        child: Consumer<AdminViewModel>(
          builder: (context, vm, _) {
            if (vm.categories.isEmpty) {
              return const Center(child: Text('Belum ada kategori'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.categories.length,
              itemBuilder: (context, index) {
                final c = vm.categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(c.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(c.name, style: AppTypography.labelLarge),
                    subtitle: Text('${c.eventCount} Event terhubung', style: AppTypography.caption),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          onPressed: () => _showAddEditDialog(context, c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                          onPressed: () => vm.deleteCategory(c.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, CategoryModel? edit) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: edit?.name ?? '');
    final iconCtrl = TextEditingController(text: edit?.icon ?? '🎯');
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(edit == null ? 'Tambah Kategori' : 'Edit Kategori'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Nama Kategori',
                  hint: 'Contoh: Edukasi, Networking',
                  controller: nameCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Emoji Icon',
                  hint: 'Masukkan satu emoji',
                  controller: iconCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Icon wajib diisi' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                
                final cat = CategoryModel(
                  id: edit?.id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  icon: iconCtrl.text.trim(),
                  color: edit?.color ?? AppColors.primary,
                  bgColor: edit?.bgColor ?? AppColors.primaryContainer,
                  eventCount: edit?.eventCount ?? 0,
                );

                final vm = context.read<AdminViewModel>();
                if (edit == null) {
                  vm.addCategory(cat);
                } else {
                  vm.updateCategory(cat);
                }

                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }
}
