// lib/features/onboarding/views/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_strings.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/services/storage/local_storage.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Desc,
      icon: Icons.search_rounded,
      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    ),
    _OnboardingPage(
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Desc,
      icon: Icons.people_rounded,
      colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    ),
    _OnboardingPage(
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Desc,
      icon: Icons.trending_up_rounded,
      colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<LocalStorage>().onboardingDone = true;
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPageView(page: _pages[index]);
            },
          ),
          // Navigation overlay
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPaddingH,
                      vertical: 16,
                    ),
                    child: _currentPage < _pages.length - 1
                        ? TextButton(
                            onPressed: _finish,
                            child: Text(
                              AppStrings.skip,
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const Spacer(),
                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.xxl),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 8,
                          dotHeight: 8,
                          expansionFactor: 4,
                          dotColor: Colors.white38,
                          activeDotColor: Colors.white,
                          spacing: 6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                            ),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? AppStrings.getStarted
                                : AppStrings.next,
                            style: AppTypography.button.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.colors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.xxl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(40),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      page.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                page.description,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
