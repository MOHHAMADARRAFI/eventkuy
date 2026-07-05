// lib/features/organizer/tickets/organizer_tickets_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/ticket_model.dart';
import 'package:eventkuy/data/repositories/ticket_repository.dart';

class OrganizerTicketsViewModel extends ChangeNotifier {
  final ITicketRepository _ticketRepo;

  OrganizerTicketsViewModel(this._ticketRepo);

  List<TicketModel> _tickets = [];
  bool _isLoading = false;
  Map<String, dynamic> _analytics = {};

  List<TicketModel> get tickets => _tickets;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get analytics => _analytics;

  Future<void> loadTickets(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tickets = await _ticketRepo.getTickets(eventId);
      _analytics = await _ticketRepo.getTicketAnalytics(eventId);
    } catch (e) {
      debugPrint('Error loading event tickets: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTicket(TicketModel ticket) async {
    try {
      await _ticketRepo.createTicket(ticket);
      await loadTickets(ticket.eventId);
    } catch (e) {
      debugPrint('Error creating ticket: $e');
    }
  }

  Future<void> updateTicket(TicketModel ticket) async {
    try {
      await _ticketRepo.updateTicket(ticket);
      await loadTickets(ticket.eventId);
    } catch (e) {
      debugPrint('Error updating ticket: $e');
    }
  }

  Future<void> deleteTicket(String ticketId, String eventId) async {
    try {
      await _ticketRepo.deleteTicket(ticketId);
      await loadTickets(eventId);
    } catch (e) {
      debugPrint('Error deleting ticket: $e');
    }
  }

  Future<void> duplicateTicket(String ticketId, String eventId) async {
    try {
      await _ticketRepo.duplicateTicket(ticketId);
      await loadTickets(eventId);
    } catch (e) {
      debugPrint('Error duplicating ticket: $e');
    }
  }

  Future<void> toggleTicketStatus(String ticketId, bool isActive, String eventId) async {
    try {
      await _ticketRepo.updateTicketStatus(ticketId, isActive);
      await loadTickets(eventId);
    } catch (e) {
      debugPrint('Error toggling ticket status: $e');
    }
  }
}
