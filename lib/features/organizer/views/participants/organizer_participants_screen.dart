// lib/features/organizer/views/participants/organizer_participants_screen.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';

class OrganizerParticipantsScreen extends StatefulWidget {
  const OrganizerParticipantsScreen({super.key});

  @override
  State<OrganizerParticipantsScreen> createState() => _OrganizerParticipantsScreenState();
}

class _OrganizerParticipantsScreenState extends State<OrganizerParticipantsScreen> {
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'Semua';
  String _filterCheckIn = 'Semua';

  // Dummy list of participants
  final List<Map<String, dynamic>> _participants = [
    {
      'id': 'p_01',
      'name': 'Ahmad Fauzi',
      'email': 'ahmad.fauzi@gmail.com',
      'paymentStatus': 'Lunas',
      'checkIn': true,
    },
    {
      'id': 'p_02',
      'name': 'Indah Permata',
      'email': 'indah.permata@yahoo.com',
      'paymentStatus': 'Lunas',
      'checkIn': false,
    },
    {
      'id': 'p_03',
      'name': 'Roni Wijaya',
      'email': 'roni.wijaya@outlook.com',
      'paymentStatus': 'Menunggu',
      'checkIn': false,
    },
    {
      'id': 'p_04',
      'name': 'Jessica Mila',
      'email': 'jessica.mila@gmail.com',
      'paymentStatus': 'Lunas',
      'checkIn': true,
    },
    {
      'id': 'p_05',
      'name': 'Budi Setiawan',
      'email': 'budi.setiawan@gmail.com',
      'paymentStatus': 'Gagal',
      'checkIn': false,
    },
  ];

  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = List.from(_participants);
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilters);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filteredList = _participants.where((p) {
        final matchesSearch = p['name'].toString().toLowerCase().contains(query) ||
            p['email'].toString().toLowerCase().contains(query);
        
        final matchesPayment = _filterStatus == 'Semua' || p['paymentStatus'] == _filterStatus;
        final matchesCheckIn = _filterCheckIn == 'Semua' ||
            (_filterCheckIn == 'Sudah Check In' && p['checkIn'] == true) ||
            (_filterCheckIn == 'Belum Check In' && p['checkIn'] == false);

        return matchesSearch && matchesPayment && matchesCheckIn;
      }).toList();
    });
  }

  void _exportCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulasi Ekspor CSV Berhasil! File saved to Downloads/participants.csv')),
    );
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulasi Ekspor Excel Berhasil! File saved to Downloads/participants.xlsx')),
    );
  }

  void _printAttendance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka dialog cetak kehadiran (Simulasi)')),
    );
  }

  void _showBroadcastModal() {
    final formKey = GlobalKey<FormState>();
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kirim Pengumuman (Broadcast)'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Subjek Email',
                  hint: 'Masukkan subjek email',
                  controller: subjectCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Subjek wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Pesan',
                  hint: 'Tulis pesan pengumuman...',
                  controller: messageCtrl,
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty ? 'Pesan wajib diisi' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Broadcast berhasil dikirim ke semua peserta!'), backgroundColor: AppColors.success),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Kirim'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Peserta', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Export / Command Toolbar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Export CSV'),
                    onPressed: _exportCSV,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.table_view_outlined, size: 16),
                    label: const Text('Excel'),
                    onPressed: _exportExcel,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Print Kehadiran'),
                    onPressed: _printAttendance,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.campaign_outlined, size: 16),
                    label: const Text('Broadcast'),
                    onPressed: _showBroadcastModal,
                  ),
                ],
              ),
            ),

            // Search Bar & Filter chips
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

            // Dropdowns Filter bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterStatus,
                      decoration: const InputDecoration(labelText: 'Status Bayar', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                        DropdownMenuItem(value: 'Lunas', child: Text('Lunas')),
                        DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                        DropdownMenuItem(value: 'Gagal', child: Text('Gagal')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _filterStatus = val;
                          _applyFilters();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterCheckIn,
                      decoration: const InputDecoration(labelText: 'Check In', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                        DropdownMenuItem(value: 'Sudah Check In', child: Text('Sudah Check In')),
                        DropdownMenuItem(value: 'Belum Check In', child: Text('Belum Check In')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _filterCheckIn = val;
                          _applyFilters();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Participants Table/List
            Expanded(
              child: _filteredList.isEmpty
                  ? const Center(child: Text('Peserta tidak ditemukan'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        final p = _filteredList[index];
                        return _buildParticipantCard(p, isDark);
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> p, bool isDark) {
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
            child: Text(p['name'].toString()[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'] as String, style: AppTypography.labelLarge),
                Text(p['email'] as String, style: AppTypography.caption),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Payment badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: p['paymentStatus'] == 'Lunas'
                            ? AppColors.successLight
                            : p['paymentStatus'] == 'Menunggu'
                                ? AppColors.warningLight
                                : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p['paymentStatus'] as String,
                        style: TextStyle(
                            color: p['paymentStatus'] == 'Lunas'
                                ? AppColors.success
                                : p['paymentStatus'] == 'Menunggu'
                                    ? AppColors.warningDark
                                    : AppColors.error,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Check-in status
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          p['checkIn'] = !(p['checkIn'] as bool);
                          _applyFilters();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (p['checkIn'] as bool) ? AppColors.successLight : AppColors.border,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (p['checkIn'] as bool) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              size: 10,
                              color: (p['checkIn'] as bool) ? AppColors.success : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (p['checkIn'] as bool) ? 'Check-in' : 'Absen',
                              style: TextStyle(
                                  color: (p['checkIn'] as bool) ? AppColors.success : Colors.black45,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'ticket', child: Text('Lihat Tiket')),
              PopupMenuItem(value: 'cert', child: Text('Kirim Sertifikat')),
              PopupMenuItem(value: 'email', child: Text('Hubungi via Email')),
            ],
            onSelected: (val) {
              if (val == 'ticket') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengunduh tiket pendaftar (Simulasi).')));
              } else if (val == 'cert') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-Sertifikat berhasil dikirim!'), backgroundColor: AppColors.success));
              } else if (val == 'email') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mengalihkan ke e-mail pendaftar: ${p['email']}')));
              }
            },
          )
        ],
      ),
    );
  }
}
