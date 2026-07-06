// lib/features/admin/settings/admin_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/data/models/user_model.dart';
import 'package:eventkuy/data/models/category_model.dart';
import 'package:eventkuy/data/models/audit_log_model.dart';
import 'package:eventkuy/data/models/organizer_model.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';
import 'package:eventkuy/data/repositories/user_repository.dart';
import 'package:eventkuy/data/repositories/audit_repository.dart';
import 'package:eventkuy/data/dummy/dummy_data.dart';

class AdminViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  // ignore: unused_field
  final UserRepository _userRepo;
  final IAuditRepository _auditRepo;

  AdminViewModel(this._eventRepo, this._userRepo, this._auditRepo);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  List<OrganizerModel> _organizers = [];
  List<EventModel> _allEvents = [];
  List<CategoryModel> _categories = [];
  List<AuditLogModel> _auditLogs = [];

  // Complaint list
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 'comp_01',
      'title': 'Spamming deskripsi event di Flutter Workshop',
      'target': 'Flutter Workshop Bali',
      'reporter': 'Roni Wijaya',
      'type': 'Event Report',
      'status': 'Review',
    },
    {
      'id': 'comp_02',
      'title': 'Permintaan refund - Tiket VIP dibatalkan sepihak',
      'target': 'Music Festival 2024',
      'reporter': 'Ahmad Fauzi',
      'type': 'Refund Request',
      'status': 'Resolved',
    },
    {
      'id': 'comp_03',
      'title': 'Kategori duplikat dan membingungkan',
      'target': 'Platform Category System',
      'reporter': 'Indah Permata',
      'type': 'Sistem Komplain',
      'status': 'Review',
    },
  ];

  // Getters
  List<UserModel> get users => _filteredUsers;
  List<OrganizerModel> get organizers => _organizers;
  List<EventModel> get allEvents => _allEvents;
  List<CategoryModel> get categories => _categories;
  List<Map<String, dynamic>> get complaints => _complaints;
  List<AuditLogModel> get auditLogs => _auditLogs;

  Future<void> loadAdminData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load users (Participant / Organizer / Admin)
      // Since UserRepository doesn't expose list all users, we map from DummyData directly
      _users = [
        DummyData.currentUser,
        UserModel(
          id: 'user_002',
          name: 'Indah Permata',
          email: 'indah.permata@yahoo.com',
          interests: ['desain', 'marketing'],
          joinedAt: Offset(0, 0) == Offset.zero ? DateTime(2024, 2, 10) : DateTime.now(),
          totalRegistrations: 4,
          totalBookmarks: 2,
        ),
        UserModel(
          id: 'org_001_user',
          name: 'GDSC Indonesia Admin',
          email: 'gdsc@indonesia.dev',
          interests: const [],
          role: UserRole.organizer,
          organizationName: 'GDSC Indonesia',
          verificationStatus: VerificationStatus.approved,
          joinedAt: DateTime(2023, 8, 1),
          totalRegistrations: 0,
          totalBookmarks: 0,
        ),
        UserModel(
          id: 'admin_001_user',
          name: 'Supriadi',
          email: 'supriadi.admin@eventkuy.id',
          interests: const [],
          role: UserRole.admin,
          joinedAt: DateTime(2022, 1, 1),
          totalRegistrations: 0,
          totalBookmarks: 0,
        ),
        UserModel(
          id: 'org_pending_user',
          name: 'Tech Communities ID',
          email: 'contact@techcom.id',
          interests: const [],
          role: UserRole.participant, // Not approved yet
          organizationName: 'Tech Communities ID',
          verificationStatus: VerificationStatus.pending,
          joinedAt: DateTime(2025, 6, 20),
          totalRegistrations: 0,
          totalBookmarks: 0,
        ),
      ];

      _filteredUsers = List.from(_users);

      // 2. Load Organizers details
      _organizers = List.from(DummyData.organizers);

      // 3. Load Categories
      _categories = List.from(DummyData.categories);

      // 4. Load all Events
      _allEvents = await _eventRepo.getEvents();

      // 5. Load Audit logs
      _auditLogs = await _auditRepo.getLogs();

    } catch (e) {
      debugPrint('Error loading admin data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter users
  void filterUsers(UserRole? role, String query) {
    var list = List<UserModel>.from(_users);
    if (role != null) {
      list = list.where((u) => u.role == role).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList();
    }
    _filteredUsers = list;
    notifyListeners();
  }

  // Update user status
  Future<void> suspendUser(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      // In real life call API. Here we mock:
      final user = _users[idx];
      _users[idx] = user.copyWith(bio: 'SUSPENDED');
      _filteredUsers = List.from(_users);
      notifyListeners();
    }
  }

  // Verify Organizer
  Future<void> verifyOrganizer(String orgName, bool approve) async {
    final idx = _users.indexWhere((u) => u.organizationName == orgName);
    if (idx != -1) {
      final user = _users[idx];
      _users[idx] = user.copyWith(
        verificationStatus: approve ? VerificationStatus.approved : VerificationStatus.rejected,
        role: approve ? UserRole.organizer : UserRole.participant,
      );
      _filteredUsers = List.from(_users);
      notifyListeners();
    }
  }

  // Approve Event
  Future<void> reviewEvent(String eventId, bool approve) async {
    final idx = _allEvents.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      _allEvents[idx] = _allEvents[idx].copyWith(
        status: approve ? EventStatus.approved : EventStatus.rejected,
      );
      notifyListeners();
    }
  }

  // Category CRUD
  void addCategory(CategoryModel cat) {
    _categories.add(cat);
    notifyListeners();
  }

  void updateCategory(CategoryModel cat) {
    final idx = _categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) {
      _categories[idx] = cat;
      notifyListeners();
    }
  }

  void deleteCategory(String catId) {
    _categories.removeWhere((c) => c.id == catId);
    notifyListeners();
  }

  // Complaint actions
  void updateComplaintStatus(String cmpId, String status) {
    final idx = _complaints.indexWhere((c) => c['id'] == cmpId);
    if (idx != -1) {
      _complaints[idx]['status'] = status;
      notifyListeners();
    }
  }

  // Push broadcast announcement
  void sendBroadcast(String audience, String subject, String message) {
    // Mimic API log
    _auditLogs.insert(
      0,
      AuditLogModel(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'admin_01',
        userName: 'Supriadi',
        role: UserRole.admin,
        action: 'Publish Announcement',
        target: audience,
        description: 'Subjek: $subject, Target: $audience',
        createdAt: DateTime.now(),
        ipAddress: '127.0.0.1',
        device: 'System Emulator',
      ),
    );
    notifyListeners();
  }
}
