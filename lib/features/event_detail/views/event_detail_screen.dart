// lib/features/event_detail/views/event_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_strings.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/features/bookmark/viewmodels/bookmark_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_dialog.dart';
import 'package:eventkuy/shared/widgets/empty_state_widget.dart';
import 'package:eventkuy/features/event_detail/viewmodels/event_detail_viewmodel.dart';
import 'package:eventkuy/features/payment/presentation/pages/ticket_payment_flow.dart';
import 'package:eventkuy/data/repositories/ticket_repository.dart';
import 'package:eventkuy/data/models/ticket_model.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvent());
  }

  void _loadEvent() {
    final userId = context.read<AuthViewModel>().currentUser?.id ?? 'user_001';
    context.read<EventDetailViewModel>().loadEvent(widget.eventId, userId);
  }

  Future<void> _toggleBookmark() async {
    final userId = context.read<AuthViewModel>().currentUser?.id ?? 'user_001';
    final vm = context.read<EventDetailViewModel>();
    final wasBookmarked = vm.isBookmarked;
    final success = await vm.toggleBookmark(userId);
    if (success && mounted) {
      context.showSnack(
        wasBookmarked ? AppStrings.bookmarkRemoved : AppStrings.bookmarkAdded,
        backgroundColor: wasBookmarked ? AppColors.textSecondary : AppColors.success,
      );
      context.read<BookmarkViewModel>().loadBookmarks(userId);
    }
  }

  Future<void> _register() async {
    final event = context.read<EventDetailViewModel>().event;
    if (event == null) return;

    final ticketRepo = context.read<ITicketRepository>();
    final ticketsList = await ticketRepo.getTickets(event.id);

    final tickets = ticketsList.isNotEmpty
        ? ticketsList
        : [
            TicketModel(
              id: 'tck_default',
              eventId: event.id,
              ticketName: 'Regular Ticket',
              description: 'Tiket masuk umum.',
              price: event.price ?? 0,
              quota: event.quota,
              remainingQuota: event.quota - event.registered,
              soldQuantity: event.registered,
              registrationStart: DateTime.now(),
              registrationEnd: event.startDate,
              benefits: event.benefits,
              isActive: true,
              maxPurchasePerUser: 4,
              colorLabel: 'blue',
              sortOrder: 1,
            )
          ];

    if (!mounted) return;

    final selectedTicket = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TicketSelectionSheet(
          tickets: tickets,
          isDark: Theme.of(context).brightness == Brightness.dark,
        );
      },
    );

    if (selectedTicket == null || !mounted) return;

    final TicketModel ticket = selectedTicket['ticket'] as TicketModel;
    final int qty = selectedTicket['quantity'] as int;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Checkout Tiket',
      message: 'Anda akan membeli ${qty}x ${ticket.ticketName} senilai ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(ticket.price * qty)}. Lanjut ke pembayaran?',
      confirmLabel: 'Lanjut',
      icon: Icons.shopping_cart_checkout_rounded,
    );

    if (confirmed != true || !mounted) return;

    final paymentSuccess = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSelectionScreen(
          ticketCount: qty,
          totalPrice: (ticket.price * qty).toInt(),
        ),
      ),
    );

    if (paymentSuccess == true && mounted) {
      final userId = context.read<AuthViewModel>().currentUser?.id ?? 'user_001';
      final success = await context.read<EventDetailViewModel>().registerForEvent(userId);

      if (!mounted) return;
      if (success) {
        context.showSnack(
          'Pembayaran berhasil! Tiket ditambahkan ke Event Saya.',
          backgroundColor: AppColors.success,
        );
        context.go('/my-event');
      } else {
        context.showErrorSnack('Pendaftaran gagal. Coba lagi.');
      }
    }
  }

  void _share() {
    final event = context.read<EventDetailViewModel>().event;
    if (event == null) return;
    Share.share(
      '🎉 ${event.title}\n📅 ${event.startDate.formattedDateShort}\n📍 ${event.location}\n\nCek di EventKuy: https://eventkuy.id/event/${event.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (vm.state == DetailState.error || vm.event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(
              message: vm.error ?? 'Event tidak ditemukan',
              onRetry: _loadEvent,
            ),
          );
        }
        return _EventDetailBody(
          event: vm.event!,
          isBookmarked: vm.isBookmarked,
          isRegistered: vm.isRegistered,
          isRegistering: vm.isRegistering,
          onBookmark: _toggleBookmark,
          onRegister: _register,
          onShare: _share,
        );
      },
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  final EventModel event;
  final bool isBookmarked;
  final bool isRegistered;
  final bool isRegistering;
  final VoidCallback onBookmark;
  final VoidCallback onRegister;
  final VoidCallback onShare;

  const _EventDetailBody({
    required this.event,
    required this.isBookmarked,
    required this.isRegistered,
    required this.isRegistering,
    required this.onBookmark,
    required this.onRegister,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Collapsible Header ─────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor:
                    isDark ? AppColors.darkBackground : AppColors.background,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        _ActionBtn(
                          icon: Icons.share_rounded,
                          onTap: onShare,
                        ),
                        const SizedBox(width: 8),
                        _ActionBtn(
                          icon: isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked ? AppColors.primary : null,
                          onTap: onBookmark,
                        ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'event_image_${event.id}',
                    child: CachedNetworkImage(
                      imageUrl: event.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.cardGradient,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.cardGradient,
                        ),
                        child: const Icon(Icons.event_rounded,
                            color: Colors.white, size: 64),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Detail Content ─────────────────
              SliverToBoxAdapter(
                child: _DetailContent(event: event, isDark: isDark),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // ── Register Button ────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Price info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.priceLabel,
                        style: AppTypography.price,
                      ),
                      Text(
                        '${event.seatsLeft} ${AppStrings.seatLeft}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Register button
                  Expanded(
                    child: AppPrimaryButton(
                      label: isRegistered ? '✓ Sudah Terdaftar' : AppStrings.registerEvent,
                      onTap: isRegistered ? null : onRegister,
                      isLoading: isRegistering,
                      backgroundColor: isRegistered ? AppColors.success : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Icon(icon,
            size: 18,
            color: color ?? Colors.white),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final EventModel event;
  final bool isDark;

  const _DetailContent({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge + mode
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: event.eventType.bgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(event.eventType.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: event.eventType.color,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(event.mode.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                  const SizedBox(width: 3),
                  Text(event.rating.toStringAsFixed(1),
                      style: AppTypography.labelMedium),
                ]),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(event.title, style: AppTypography.headlineMedium),
            const SizedBox(height: 16),

            // Info cards
            _InfoCard(
              icon: Icons.calendar_today_rounded,
              label: AppStrings.date,
              value: event.startDate.formattedDateTime,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.location_on_rounded,
              label: AppStrings.location,
              value: event.location,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.people_rounded,
              label: AppStrings.quota,
              value: '${event.registered}/${event.quota} peserta terdaftar',
              isDark: isDark,
              trailing: LinearProgressIndicator(
                value: event.registered / event.quota,
                backgroundColor: AppColors.border,
                color: event.isFull ? AppColors.error : AppColors.primary,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Organizer
            const SizedBox(height: 20),
            _SectionTitle(AppStrings.organizer, isDark),
            const SizedBox(height: 10),
            _OrganizerRow(event: event, isDark: isDark),

            // Description
            const SizedBox(height: 20),
            _SectionTitle(AppStrings.about, isDark),
            const SizedBox(height: 10),
            Text(event.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  height: 1.7,
                )),

            // Benefits
            if (event.benefits.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(AppStrings.benefit, isDark),
              const SizedBox(height: 10),
              ...event.benefits.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 10, top: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.successLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              size: 12, color: AppColors.success),
                        ),
                        Expanded(
                          child: Text(b,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              )),
                        ),
                      ],
                    ),
                  )),
            ],

            // Speakers
            if (event.speakers.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(AppStrings.speaker, isDark),
              const SizedBox(height: 10),
              ...event.speakers.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull),
                          child: CachedNetworkImage(
                            imageUrl: s.photoUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 48,
                              height: 48,
                              color: AppColors.primaryContainer,
                              child: Icon(Icons.person_rounded,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: AppTypography.titleSmall),
                              Text('${s.title} • ${s.company}',
                                  style: AppTypography.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            // Agenda
            if (event.agenda.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(AppStrings.agenda, isDark),
              const SizedBox(height: 10),
              ...event.agenda.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isLast = i == event.agenda.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 40,
                            color: AppColors.border,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.time,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                )),
                            Text(item.title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                )),
                            if (item.description != null)
                              Text(item.description!,
                                  style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle(this.title, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.headlineSmall.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                Text(value,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    )),
                if (trailing != null) ...[
                  const SizedBox(height: 6),
                  trailing!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizerRow extends StatelessWidget {
  final EventModel event;
  final bool isDark;

  const _OrganizerRow({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final org = event.organizer;
    return GestureDetector(
      onTap: () => context.push('/organizer-profile/${org.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: CachedNetworkImage(
                imageUrl: org.logoUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 44,
                  height: 44,
                  color: AppColors.primaryContainer,
                  child: Text(
                    org.name[0],
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(org.name, style: AppTypography.titleSmall),
                      if (org.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 14, color: AppColors.primary),
                      ],
                    ],
                  ),
                  Text('${org.totalEvents} event • ${org.formattedFollowers} followers',
                      style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _TicketSelectionSheet extends StatefulWidget {
  final List<TicketModel> tickets;
  final bool isDark;

  const _TicketSelectionSheet({required this.tickets, required this.isDark});

  @override
  State<_TicketSelectionSheet> createState() => _TicketSelectionSheetState();
}

class _TicketSelectionSheetState extends State<_TicketSelectionSheet> {
  TicketModel? _selectedTicket;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    if (widget.tickets.isNotEmpty) {
      _selectedTicket = widget.tickets.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final curFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Pilih Jenis Tiket', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.tickets.length,
              itemBuilder: (context, index) {
                final t = widget.tickets[index];
                final isSel = _selectedTicket?.id == t.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTicket = t;
                      _qty = 1;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : (widget.isDark ? AppColors.darkSurface : AppColors.surface),
                      border: Border.all(
                        color: isSel ? AppColors.primary : (widget.isDark ? AppColors.darkBorder : AppColors.border),
                        width: isSel ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.ticketName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                              Text(t.description, style: AppTypography.caption),
                              const SizedBox(height: 4),
                              Text('Tersisa: ${t.remainingQuota}', style: AppTypography.caption.copyWith(color: AppColors.error)),
                            ],
                          ),
                        ),
                        Text(curFormat.format(t.price), style: AppTypography.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          if (_selectedTicket != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jumlah Tiket', style: AppTypography.bodyMedium),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                    ),
                    Text('$_qty', style: AppTypography.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: _qty < _selectedTicket!.maxPurchasePerUser && _qty < _selectedTicket!.remainingQuota
                          ? () => setState(() => _qty++)
                          : null,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  curFormat.format(_selectedTicket!.price * _qty),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {'ticket': _selectedTicket, 'quantity': _qty});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  'Lanjut ke Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
