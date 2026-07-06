// lib/features/organizer/views/create_event/organizer_create_event_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/data/models/category_model.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/models/organizer_model.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/features/organizer/events/organizer_events_viewmodel.dart';

class OrganizerCreateEventScreen extends StatefulWidget {
  final EventModel? eventToEdit; // If supplied, works as Edit Event Screen

  const OrganizerCreateEventScreen({super.key, this.eventToEdit});

  @override
  State<OrganizerCreateEventScreen> createState() => _OrganizerCreateEventScreenState();
}

class _OrganizerCreateEventScreenState extends State<OrganizerCreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _quotaCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _mapsLinkCtrl;
  late final TextEditingController _sponsorsCtrl;
  late final TextEditingController _refundCtrl;
  late final TextEditingController _termsCtrl;

  CategoryModel? _selectedCategory;
  EventType _selectedType = EventType.seminar;
  EventMode _selectedMode = EventMode.offline;

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7, hours: 3));
  DateTime _deadlineDate = DateTime.now().add(const Duration(days: 6));

  List<String> _benefits = [];
  List<SpeakerModel> _speakers = [];
  List<AgendaItem> _agenda = [];
  List<FaqItem> _faqs = [];
  
  bool _certAvailable = false;
  String _bannerUrl = 'https://picsum.photos/seed/event_banner/800/400';

  @override
  void initState() {
    super.initState();
    final edit = widget.eventToEdit;
    _titleCtrl = TextEditingController(text: edit?.title ?? '');
    _descCtrl = TextEditingController(text: edit?.description ?? '');
    _locationCtrl = TextEditingController(text: edit?.location ?? '');
    _priceCtrl = TextEditingController(text: edit?.price?.toString() ?? '0');
    _quotaCtrl = TextEditingController(text: edit?.quota.toString() ?? '100');
    _contactCtrl = TextEditingController(text: edit?.contactPerson ?? '');
    _mapsLinkCtrl = TextEditingController(text: edit?.googleMapsLink ?? '');
    _sponsorsCtrl = TextEditingController(text: edit?.sponsors.join(', ') ?? '');
    _refundCtrl = TextEditingController(text: edit?.refundPolicy ?? '');
    _termsCtrl = TextEditingController(text: edit?.termsConditions ?? '');

    if (edit != null) {
      _selectedType = edit.eventType;
      _selectedMode = edit.mode;
      _startDate = edit.startDate;
      _endDate = edit.endDate;
      _deadlineDate = edit.registrationDeadline ?? edit.startDate.subtract(const Duration(days: 1));
      _benefits = List.from(edit.benefits);
      _speakers = List.from(edit.speakers);
      _agenda = List.from(edit.agenda);
      _faqs = List.from(edit.faq);
      _certAvailable = edit.certificateAvailable;
      _bannerUrl = edit.posterUrl;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _quotaCtrl.dispose();
    _contactCtrl.dispose();
    _mapsLinkCtrl.dispose();
    _sponsorsCtrl.dispose();
    _refundCtrl.dispose();
    _termsCtrl.dispose();
    super.dispose();
  }

  EventModel _buildEventPayload(BuildContext context, EventStatus status) {
    final authVm = context.read<AuthViewModel>();
    final org = authVm.currentUser;

    return EventModel(
      id: widget.eventToEdit?.id ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      posterUrl: _bannerUrl,
      categoryId: _selectedCategory?.id ?? 'teknologi',
      categoryName: _selectedCategory?.name ?? 'Teknologi',
      eventType: _selectedType,
      mode: _selectedMode,
      organizer: OrganizerModel(
        id: org?.id ?? 'org_001',
        name: org?.organizationName ?? org?.name ?? 'GDSC Indonesia',
        logoUrl: org?.organizationLogo ?? 'https://picsum.photos/seed/gdsc/200/200',
        description: org?.bio ?? '',
        location: org?.location ?? 'Jakarta, Indonesia',
        website: 'https://gdsc.community.dev',
        rating: 4.8,
        totalEvents: 10,
        followers: 120,
        isVerified: true,
        tags: const [],
      ),
      startDate: _startDate,
      endDate: _endDate,
      location: _locationCtrl.text.trim(),
      mapsUrl: _mapsLinkCtrl.text.trim(),
      isFree: int.tryParse(_priceCtrl.text) == 0,
      price: int.tryParse(_priceCtrl.text),
      quota: int.tryParse(_quotaCtrl.text) ?? 100,
      registered: widget.eventToEdit?.registered ?? 0,
      benefits: _benefits,
      speakers: _speakers,
      agenda: _agenda,
      tags: const ['Seminar', 'Teknologi'],
      isTrending: false,
      isFeatured: false,
      rating: 5.0,
      views: widget.eventToEdit?.views ?? 0,
      createdAt: widget.eventToEdit?.createdAt ?? DateTime.now(),
      status: status,
      galleryUrls: const [],
      registrationDeadline: _deadlineDate,
      faq: _faqs,
      refundPolicy: _refundCtrl.text.trim(),
      termsConditions: _termsCtrl.text.trim(),
      sponsors: _sponsorsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      contactPerson: _contactCtrl.text.trim(),
      certificateAvailable: _certAvailable,
      certificateTemplateUrl: _certAvailable ? 'https://picsum.photos/seed/certificate/800/600' : null,
      googleMapsLink: _mapsLinkCtrl.text.trim(),
    );
  }

  void _saveEvent(EventStatus status) async {
    if (!_formKey.currentState!.validate()) return;
    
    final payload = _buildEventPayload(context, status);
    final eventsVm = context.read<OrganizerEventsViewModel>();

    if (widget.eventToEdit != null) {
      await eventsVm.updateEvent(payload);
      if (mounted) {
        context.showSnack('Event berhasil diupdate!', backgroundColor: AppColors.success);
      }
    } else {
      await eventsVm.createEvent(payload);
      if (mounted) {
        context.showSnack(
          status == EventStatus.draft ? 'Draft berhasil disimpan' : 'Event berhasil diajukan untuk review!',
          backgroundColor: AppColors.success,
        );
      }
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.eventToEdit != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Event' : 'Buat Event Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Selector Mock
                _buildBannerSelector(isDark),
                const SizedBox(height: 20),

                // Step 1: Informasi Dasar
                _buildSectionTitle('Informasi Dasar'),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Judul Event',
                  hint: 'Masukkan judul event',
                  controller: _titleCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Judul event wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Deskripsi Event',
                  hint: 'Masukkan deskripsi lengkap event',
                  controller: _descCtrl,
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty ? 'Deskripsi event wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Category & Event Type Selectors
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<EventType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(labelText: 'Tipe Event'),
                        items: EventType.values
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<EventMode>(
                        initialValue: _selectedMode,
                        decoration: const InputDecoration(labelText: 'Mode Event'),
                        items: EventMode.values
                            .map((m) => DropdownMenuItem(value: m, child: Text(m.name.toUpperCase())))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMode = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Lokasi Event',
                  hint: 'Masukkan alamat lokasi atau "Zoom Link" jika online',
                  controller: _locationCtrl,
                  prefixIcon: Icons.location_on_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Google Maps Link',
                  hint: 'Contoh: https://maps.google.com/?q=...',
                  controller: _mapsLinkCtrl,
                  prefixIcon: Icons.map_rounded,
                ),
                const SizedBox(height: 24),

                // Step 2: Waktu & Tiket
                _buildSectionTitle('Waktu, Kuota & Tiket'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Tanggal Mulai', style: TextStyle(fontSize: 12)),
                        subtitle: Text(_startDate.toString().substring(0, 16)),
                        trailing: const Icon(Icons.date_range_rounded),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null && mounted) {
                            setState(() => _startDate = DateTime(date.year, date.month, date.day, _startDate.hour, _startDate.minute));
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Tanggal Selesai', style: TextStyle(fontSize: 12)),
                        subtitle: Text(_endDate.toString().substring(0, 16)),
                        trailing: const Icon(Icons.date_range_rounded),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null && mounted) {
                            setState(() => _endDate = DateTime(date.year, date.month, date.day, _endDate.hour, _endDate.minute));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Harga Tiket (IDR)',
                        hint: '0 untuk gratis',
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Harga wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: 'Kapasitas Peserta',
                        hint: 'Masukkan kuota',
                        controller: _quotaCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.people_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Kuota wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Step 3: Speakers & Agenda (Simulated inputs)
                _buildSectionTitle('Speaker & Agenda'),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.person_add_rounded, color: AppColors.primary),
                  title: const Text('Tambah Speaker'),
                  subtitle: Text('${_speakers.length} Speaker terdaftar'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    setState(() {
                      _speakers.add(SpeakerModel(
                        name: 'Speaker Baru ${_speakers.length + 1}',
                        title: 'Expert Engineer',
                        company: 'Tech Company',
                        photoUrl: 'https://picsum.photos/seed/spk_new/100/100',
                      ));
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
                  title: const Text('Tambah Agenda / Sesi'),
                  subtitle: Text('${_agenda.length} Sesi terdaftar'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    setState(() {
                      _agenda.add(AgendaItem(
                        time: '09:00',
                        title: 'Sesi Baru ${_agenda.length + 1}',
                        description: 'Detail materi pembahasan.',
                      ));
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Additional details: Certificates, FAQ, Policies
                _buildSectionTitle('Sertifikat, Kebijakan & Sponsor'),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('E-Sertifikat Tersedia'),
                  subtitle: const Text('Kirim sertifikat otomatis setelah event selesai'),
                  value: _certAvailable,
                  onChanged: (val) => setState(() => _certAvailable = val),
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Kebijakan Pengembalian (Refund)',
                  hint: 'Masukkan syarat refund tiket...',
                  controller: _refundCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Sponsor / Partner (Pisahkan koma)',
                  hint: 'Contoh: Google, Dicoding, UI',
                  controller: _sponsorsCtrl,
                  prefixIcon: Icons.handshake_rounded,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Contact Person',
                  hint: 'Masukkan nama / no WhatsApp kontak CP',
                  controller: _contactCtrl,
                  prefixIcon: Icons.contact_phone_rounded,
                ),
                const SizedBox(height: 36),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Preview',
                        onTap: () {
                          if (!_formKey.currentState!.validate()) return;
                          final previewPayload = _buildEventPayload(context, EventStatus.draft);
                          _showPreviewDialog(context, previewPayload);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppPrimaryButton(
                        label: isEdit ? 'Update' : 'Ajukan Review',
                        onTap: () => _saveEvent(isEdit ? (widget.eventToEdit!.status) : EventStatus.submittedForReview),
                      ),
                    ),
                  ],
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _saveEvent(EventStatus.draft),
                      child: const Text('Simpan sebagai Draft', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildBannerSelector(bool isDark) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Simulasi upload poster/banner event.')),
        );
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          image: DecorationImage(
            image: NetworkImage(_bannerUrl),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_rounded, size: 44, color: AppColors.primary),
              SizedBox(height: 8),
              Text('Unggah Poster / Banner Event', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Ukuran rekomendasi 16:9', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  // Interactive full preview dialog simulating Event details before submitting
  void _showPreviewDialog(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBackground
                    : AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(event.posterUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 16),
                        Text('[PREVIEW MODE]', style: AppTypography.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
                        Text(event.title, style: AppTypography.headlineLarge),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(event.startDate.toString().substring(0, 16), style: AppTypography.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(event.location, style: AppTypography.bodyMedium)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Deskripsi', style: AppTypography.titleLarge),
                        const SizedBox(height: 8),
                        Text(event.description, style: AppTypography.bodyMedium),
                        const SizedBox(height: 36),
                        AppPrimaryButton(
                          label: 'Tutup Preview',
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
