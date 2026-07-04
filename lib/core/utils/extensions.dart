// lib/core/utils/extensions.dart
// Useful extensions for cleaner code across the app

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

// ── String Extensions ─────────────────────────────────
extension StringExt on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((word) => word.isEmpty ? word : word.capitalize)
      .join(' ');

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }

  bool get isValidPassword => length >= 8;

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}

// ── DateTime Extensions ───────────────────────────────
extension DateTimeExt on DateTime {
  String get formattedDate => DateFormat('d MMMM yyyy', 'id_ID').format(this);
  String get formattedDateShort => DateFormat('d MMM yyyy', 'id_ID').format(this);
  String get formattedTime => DateFormat('HH:mm', 'id_ID').format(this);
  String get formattedDateTime =>
      DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(this);
  String get formattedDay => DateFormat('EEEE', 'id_ID').format(this);
  String get formattedMonth => DateFormat('MMMM yyyy', 'id_ID').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays > 30) return formattedDateShort;
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }

  String get countdown {
    final now = DateTime.now();
    if (isBefore(now)) return 'Sudah berlalu';
    final diff = difference(now);
    if (diff.inDays > 30) return formattedDateShort;
    if (diff.inDays > 0) return '${diff.inDays} hari lagi';
    if (diff.inHours > 0) return '${diff.inHours} jam lagi';
    return 'Segera dimulai';
  }
}

// ── int Extensions ────────────────────────────────────
extension IntExt on int {
  String get formattedCurrency =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(this);

  String get formattedNumber =>
      NumberFormat('#,###', 'id_ID').format(this);

  String get compact => NumberFormat.compact(locale: 'id_ID').format(this);
}

// ── double Extensions ─────────────────────────────────
extension DoubleExt on double {
  String get formattedCurrency =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(this);
}

// ── BuildContext Extensions ───────────────────────────
extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
  double get topPadding => MediaQuery.of(this).padding.top;

  bool get isTablet => screenWidth >= 600;
  bool get isPhone => screenWidth < 600;

  void showSnack(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
        backgroundColor: backgroundColor ?? AppColors.textPrimary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void showSuccessSnack(String message) =>
      showSnack(message, backgroundColor: AppColors.success);

  void showErrorSnack(String message) =>
      showSnack(message, backgroundColor: AppColors.error);
}

// ── Widget Extensions ─────────────────────────────────
extension WidgetExt on Widget {
  Widget get expanded => Expanded(child: this);
  Widget get flexible => Flexible(child: this);

  Widget padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget padH(double value) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );

  Widget padV(double value) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: value),
        child: this,
      );

  Widget padOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );
}

// ── Color Extensions ──────────────────────────────────
extension ColorExt on Color {
  Color withOpacityValue(double opacity) => withAlpha((opacity * 255).round());
}
