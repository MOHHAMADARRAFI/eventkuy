// lib/features/home/widgets/banner_slider.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/event_model.dart';

class BannerSlider extends StatefulWidget {
  final List<EventModel> events;
  final void Function(EventModel) onTap;

  const BannerSlider({
    super.key,
    required this.events,
    required this.onTap,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _current = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.events.length,
          options: CarouselOptions(
            height: AppDimensions.bannerHeight,
            viewportFraction: 0.88,
            enableInfiniteScroll: widget.events.length > 1,
            autoPlay: widget.events.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
          itemBuilder: (context, index, _) {
            final event = widget.events[index];
            return _BannerItem(event: event, onTap: () => widget.onTap(event));
          },
        ),
        if (widget.events.length > 1) ...[
          const SizedBox(height: 12),
          AnimatedSmoothIndicator(
            activeIndex: _current,
            count: widget.events.length,
            effect: const ExpandingDotsEffect(
              dotWidth: 6,
              dotHeight: 6,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.border,
              expansionFactor: 3,
              spacing: 4,
            ),
          ),
        ],
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _BannerItem({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Hero(
              tag: 'banner_${event.id}',
              child: CachedNetworkImage(
                imageUrl: event.posterUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.cardGradient,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.cardGradient,
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bannerGradient,
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: event.eventType.color,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            event.eventType.label,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: event.isFree
                                ? AppColors.success
                                : AppColors.warning,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            event.priceLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      event.title,
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        shadows: [
                          const Shadow(blurRadius: 8, color: Colors.black45),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Date & location
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event.startDate),
                          style: AppTypography.caption
                              .copyWith(color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.mode == EventMode.online
                                ? 'Online'
                                : event.location.split(',').first,
                            style: AppTypography.caption
                                .copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
