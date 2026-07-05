// lib/features/organizer/dashboard/organizer_dashboard_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/models/payment_model.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';
import 'package:eventkuy/data/repositories/payment_repository.dart';

class OrganizerDashboardViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final IPaymentRepository _paymentRepo;

  OrganizerDashboardViewModel(this._eventRepo, this._paymentRepo);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalEvents = 0;
  int _activeEvents = 0;
  int _totalParticipants = 0;
  int _totalRevenue = 0;
  int _pendingPayments = 0;
  int _refundsCount = 0;
  int _todaysRevenue = 0;
  int _monthlyRevenue = 0;

  List<EventModel> _myEvents = [];
  List<PaymentModel> _recentPayments = [];

  // Getters
  int get totalEvents => _totalEvents;
  int get activeEvents => _activeEvents;
  int get totalParticipants => _totalParticipants;
  int get totalRevenue => _totalRevenue;
  int get pendingPayments => _pendingPayments;
  int get refundsCount => _refundsCount;
  int get todaysRevenue => _todaysRevenue;
  int get monthlyRevenue => _monthlyRevenue;
  List<EventModel> get myEvents => _myEvents;
  List<PaymentModel> get recentPayments => _recentPayments;

  Future<void> loadDashboardData(String organizerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get organizer events
      _myEvents = await _eventRepo.getEventsByOrganizer(organizerId);
      _totalEvents = _myEvents.length;
      
      // Calculate active events (Published/RegistrationOpen/Ongoing status)
      _activeEvents = _myEvents.where((e) =>
          e.status == EventStatus.published ||
          e.status == EventStatus.registrationOpen ||
          e.status == EventStatus.ongoing).length;

      // Sum registered participants
      _totalParticipants = _myEvents.fold(0, (sum, event) => sum + event.registered);

      // 2. Get Payments
      final allPayments = await _paymentRepo.getPayments();
      
      // Calculate revenue stats
      _totalRevenue = 0;
      _pendingPayments = 0;
      _refundsCount = 0;
      _todaysRevenue = 0;
      _monthlyRevenue = 0;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      for (var pay in allPayments) {
        if (pay.paymentStatus == PaymentStatus.paid) {
          _totalRevenue += pay.amount;
          if (pay.paymentDate != null) {
            if (pay.paymentDate!.isAfter(todayStart)) {
              _todaysRevenue += pay.amount;
            }
            if (pay.paymentDate!.isAfter(monthStart)) {
              _monthlyRevenue += pay.amount;
            }
          }
        } else if (pay.paymentStatus == PaymentStatus.pending) {
          _pendingPayments += pay.amount;
        } else if (pay.paymentStatus == PaymentStatus.refunded) {
          _refundsCount += pay.amount;
        }
      }

      // Recent transactions
      _recentPayments = allPayments.take(5).toList();

    } catch (e) {
      debugPrint('Error loading organizer dashboard data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
