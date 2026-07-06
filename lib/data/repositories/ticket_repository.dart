// lib/data/repositories/ticket_repository.dart

import '../dummy/dummy_data.dart';
import '../models/ticket_model.dart';

abstract class ITicketRepository {
  Future<List<TicketModel>> getTickets(String eventId);
  Future<TicketModel> createTicket(TicketModel ticket);
  Future<TicketModel> updateTicket(TicketModel ticket);
  Future<void> deleteTicket(String ticketId);
  Future<TicketModel> duplicateTicket(String ticketId);
  Future<void> updateTicketStatus(String ticketId, bool isActive);
  Future<Map<String, dynamic>> getTicketAnalytics(String eventId);
}

class TicketRepository implements ITicketRepository {
  // Local list acting as dummy database
  final List<TicketModel> _tickets = [];

  TicketRepository() {
    // Populate with dummy data if needed
    _tickets.addAll(DummyData.tickets);
  }

  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<List<TicketModel>> getTickets(String eventId) async {
    await _delay();
    return _tickets.where((t) => t.eventId == eventId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<TicketModel> createTicket(TicketModel ticket) async {
    await _delay();
    _tickets.add(ticket);
    return ticket;
  }

  @override
  Future<TicketModel> updateTicket(TicketModel ticket) async {
    await _delay();
    final idx = _tickets.indexWhere((t) => t.id == ticket.id);
    if (idx != -1) {
      _tickets[idx] = ticket;
    }
    return ticket;
  }

  @override
  Future<void> deleteTicket(String ticketId) async {
    await _delay();
    _tickets.removeWhere((t) => t.id == ticketId);
  }

  @override
  Future<TicketModel> duplicateTicket(String ticketId) async {
    await _delay();
    final existing = _tickets.firstWhere(
      (t) => t.id == ticketId,
      orElse: () => throw Exception('Tiket tidak ditemukan: $ticketId'),
    );
    final duplicated = TicketModel(
      id: 'tck_${DateTime.now().millisecondsSinceEpoch}',
      eventId: existing.eventId,
      ticketName: '${existing.ticketName} (Copy)',
      description: existing.description,
      price: existing.price,
      quota: existing.quota,
      remainingQuota: existing.quota,
      soldQuantity: 0,
      registrationStart: existing.registrationStart,
      registrationEnd: existing.registrationEnd,
      benefits: List.from(existing.benefits),
      isActive: existing.isActive,
      maxPurchasePerUser: existing.maxPurchasePerUser,
      colorLabel: existing.colorLabel,
      sortOrder: existing.sortOrder + 1,
    );
    _tickets.add(duplicated);
    return duplicated;
  }

  @override
  Future<void> updateTicketStatus(String ticketId, bool isActive) async {
    await _delay();
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(isActive: isActive);
    }
  }

  @override
  Future<Map<String, dynamic>> getTicketAnalytics(String eventId) async {
    await _delay();
    final eventTickets = _tickets.where((t) => t.eventId == eventId).toList();
    
    int totalSold = 0;
    int totalQuota = 0;
    int totalRevenue = 0;
    String popularTicket = '-';
    int maxSold = -1;

    for (var t in eventTickets) {
      totalSold += t.soldQuantity;
      totalQuota += t.quota;
      totalRevenue += (t.soldQuantity * t.price);
      if (t.soldQuantity > maxSold) {
        maxSold = t.soldQuantity;
        popularTicket = t.ticketName;
      }
    }

    final double conversionRate = totalQuota > 0 ? (totalSold / totalQuota) * 100 : 0.0;

    return {
      'sold': totalSold,
      'remaining': totalQuota - totalSold,
      'revenue': totalRevenue,
      'popular': popularTicket,
      'conversionRate': conversionRate,
    };
  }
}
