// lib/features/organizer/views/tickets/organizer_tickets_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/ticket_model.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/organizer/tickets/organizer_tickets_viewmodel.dart';

class OrganizerTicketsScreen extends StatefulWidget {
  final String eventId;

  const OrganizerTicketsScreen({super.key, required this.eventId});

  @override
  State<OrganizerTicketsScreen> createState() => _OrganizerTicketsScreenState();
}

class _OrganizerTicketsScreenState extends State<OrganizerTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizerTicketsViewModel>().loadTickets(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Tiket', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateEditTicketDialog(context, null),
          )
        ],
      ),
      body: Consumer<OrganizerTicketsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analytics Cards
                _buildAnalyticsPanel(vm.analytics, currencyFormat, isDark),
                const SizedBox(height: 24),

                Text('Daftar Tiket', style: AppTypography.titleLarge),
                const SizedBox(height: 12),

                if (vm.tickets.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text('Belum ada tiket dibuat. Ketuk tombol + untuk membuat.', style: AppTypography.caption),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.tickets.length,
                    itemBuilder: (context, index) {
                      final t = vm.tickets[index];
                      return _buildTicketCard(context, t, vm, currencyFormat, isDark);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsPanel(Map<String, dynamic> stats, NumberFormat format, bool isDark) {
    final sold = stats['sold'] ?? 0;
    final remaining = stats['remaining'] ?? 0;
    final revenue = stats['revenue'] ?? 0;
    final popular = stats['popular'] ?? '-';
    final rate = stats['conversionRate'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistik Penjualan Tiket', style: AppTypography.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPanelItem('Terjual', '$sold', isDark)),
              Expanded(child: _buildPanelItem('Tersisa', '$remaining', isDark)),
              Expanded(child: _buildPanelItem('Konversi', '${rate.toStringAsFixed(1)}%', isDark)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terpopuler:', style: AppTypography.caption),
              Text(popular, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenue:', style: AppTypography.caption),
              Text(format.format(revenue), style: AppTypography.labelLarge.copyWith(color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanelItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 6),
        Text(value, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketModel t, OrganizerTicketsViewModel vm, NumberFormat format, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: t.colorLabel == 'blue'
                      ? Colors.blue
                      : t.colorLabel == 'purple'
                          ? Colors.purple
                          : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(t.ticketName, style: AppTypography.titleLarge),
              const Spacer(),
              Switch(
                value: t.isActive,
                onChanged: (val) => vm.toggleTicketStatus(t.id, val, widget.eventId),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.description, style: AppTypography.caption),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(format.format(t.price), style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
              Text('${t.soldQuantity} / ${t.quota} Terjual', style: AppTypography.caption),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => vm.duplicateTicket(t.id, widget.eventId),
                tooltip: 'Duplikasi',
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: () => _showCreateEditTicketDialog(context, t),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                onPressed: () => vm.deleteTicket(t.id, widget.eventId),
                tooltip: 'Hapus',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateEditTicketDialog(BuildContext context, TicketModel? edit) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: edit?.ticketName ?? '');
    final descCtrl = TextEditingController(text: edit?.description ?? '');
    final priceCtrl = TextEditingController(text: edit?.price.toString() ?? '0');
    final quotaCtrl = TextEditingController(text: edit?.quota.toString() ?? '100');
    final limitCtrl = TextEditingController(text: edit?.maxPurchasePerUser.toString() ?? '4');
    String color = edit?.colorLabel ?? 'blue';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(edit == null ? 'Buat Tiket Baru' : 'Edit Tiket'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Nama Tiket',
                    hint: 'VIP, Early Bird, Regular',
                    controller: nameCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Nama tiket wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Deskripsi',
                    hint: 'Fasilitas / hak akses tiket',
                    controller: descCtrl,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Harga (IDR)',
                          hint: '0 = gratis',
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Harga wajib diisi' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Kuota',
                          hint: 'Jumlah tiket',
                          controller: quotaCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Kuota wajib diisi' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Maks. Pembelian per User',
                    hint: 'Batas pembelian',
                    controller: limitCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: color,
                    decoration: const InputDecoration(labelText: 'Label Warna'),
                    items: const [
                      DropdownMenuItem(value: 'blue', child: Text('Biru')),
                      DropdownMenuItem(value: 'green', child: Text('Hijau')),
                      DropdownMenuItem(value: 'purple', child: Text('Ungu')),
                    ],
                    onChanged: (val) {
                      if (val != null) color = val;
                    },
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final ticket = TicketModel(
                  id: edit?.id ?? 'tck_${DateTime.now().millisecondsSinceEpoch}',
                  eventId: widget.eventId,
                  ticketName: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  price: int.tryParse(priceCtrl.text) ?? 0,
                  quota: int.tryParse(quotaCtrl.text) ?? 100,
                  remainingQuota: int.tryParse(quotaCtrl.text) ?? 100,
                  soldQuantity: edit?.soldQuantity ?? 0,
                  registrationStart: DateTime.now(),
                  registrationEnd: DateTime.now().add(const Duration(days: 30)),
                  benefits: const [],
                  isActive: edit?.isActive ?? true,
                  maxPurchasePerUser: int.tryParse(limitCtrl.text) ?? 4,
                  colorLabel: color,
                  sortOrder: edit?.sortOrder ?? 1,
                );
                
                final vm = context.read<OrganizerTicketsViewModel>();
                if (edit == null) {
                  vm.createTicket(ticket);
                } else {
                  vm.updateTicket(ticket);
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
