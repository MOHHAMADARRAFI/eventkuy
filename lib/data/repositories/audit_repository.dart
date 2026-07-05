// lib/data/repositories/audit_repository.dart

import '../dummy/dummy_data.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';

abstract class IAuditRepository {
  Future<List<AuditLogModel>> getLogs();
  Future<void> addLog(AuditLogModel log);
  Future<List<AuditLogModel>> filterLogs({UserRole? role, String? action, DateTime? startDate, DateTime? endDate});
  Future<List<AuditLogModel>> searchLogs(String query);
}

class AuditRepository implements IAuditRepository {
  final List<AuditLogModel> _logs = [];

  AuditRepository() {
    _logs.addAll(DummyData.auditLogs);
  }

  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<AuditLogModel>> getLogs() async {
    await _delay();
    return List.from(_logs)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addLog(AuditLogModel log) async {
    await _delay();
    _logs.add(log);
  }

  @override
  Future<List<AuditLogModel>> filterLogs({
    UserRole? role,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _delay();
    var results = List<AuditLogModel>.from(_logs);
    if (role != null) {
      results = results.where((l) => l.role == role).toList();
    }
    if (action != null && action.isNotEmpty) {
      results = results.where((l) => l.action.toLowerCase() == action.toLowerCase()).toList();
    }
    if (startDate != null) {
      results = results.where((l) => l.createdAt.isAfter(startDate) || l.createdAt.isAtSameMomentAs(startDate)).toList();
    }
    if (endDate != null) {
      results = results.where((l) => l.createdAt.isBefore(endDate) || l.createdAt.isAtSameMomentAs(endDate)).toList();
    }
    return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<AuditLogModel>> searchLogs(String query) async {
    await _delay();
    if (query.trim().isEmpty) return getLogs();
    final q = query.toLowerCase().trim();
    return _logs.where((l) {
      return l.userName.toLowerCase().contains(q) ||
          l.action.toLowerCase().contains(q) ||
          l.target.toLowerCase().contains(q) ||
          l.description.toLowerCase().contains(q);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
