// lib/data/repositories/user_repository.dart

import '../dummy/dummy_data.dart';
import '../models/registration_model.dart';
import '../models/user_model.dart';

abstract class IUserRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> login(String email, String password);
  Future<UserModel> register(String name, String email, String password, List<String> interests);
  Future<void> logout();
  Future<UserModel> updateProfile(UserModel user);
  Future<List<RegistrationModel>> getRegistrations(String userId);
  Future<void> registerForEvent(String userId, String eventId);
}

class UserRepository implements IUserRepository {
  UserModel? _currentUser;
  final List<RegistrationModel> _registrations =
      List.from(DummyData.registrations);

  Future<void> _delay() async =>
      await Future.delayed(const Duration(milliseconds: 800));

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser ?? DummyData.currentUser;
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    await _delay();
    // Demo: any email/password works
    _currentUser = DummyData.currentUser;
    return _currentUser;
  }

  @override
  Future<UserModel> register(
    String name,
    String email,
    String password,
    List<String> interests,
  ) async {
    await _delay();
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      interests: interests,
      joinedAt: DateTime.now(),
      totalRegistrations: 0,
      totalBookmarks: 0,
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await _delay();
    _currentUser = user;
    return user;
  }

  @override
  Future<List<RegistrationModel>> getRegistrations(String userId) async {
    await _delay();
    return _registrations.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
  }

  @override
  Future<void> registerForEvent(String userId, String eventId) async {
    await _delay();
    final event = DummyData.events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => throw Exception('Event tidak ditemukan: $eventId'),
    );
    _registrations.add(RegistrationModel(
      id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      event: event,
      status: RegistrationStatus.upcoming,
      registeredAt: DateTime.now(),
      ticketCode:
          'EVT-${eventId.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}',
    ));
  }
}
