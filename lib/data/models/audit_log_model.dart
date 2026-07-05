// lib/data/models/audit_log_model.dart

import 'user_model.dart';

class AuditLogModel {
  final String id;
  final String userId;
  final String userName; // To display directly in lists easily
  final UserRole role;
  final String action;
  final String target;
  final String description;
  final DateTime createdAt;
  final String ipAddress;
  final String device;

  const AuditLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.action,
    required this.target,
    required this.description,
    required this.createdAt,
    required this.ipAddress,
    required this.device,
  });
}
