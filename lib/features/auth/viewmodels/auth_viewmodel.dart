// lib/features/auth/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:eventkuy/data/models/user_model.dart';
import 'package:eventkuy/data/repositories/user_repository.dart';
import 'package:eventkuy/services/storage/local_storage.dart';

enum AuthState { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final LocalStorage _storage;

  AuthViewModel(this._userRepo, this._storage);

  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoggedIn = false;
  UserRole _activeRole = UserRole.participant;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _state == AuthState.loading;
  UserRole get activeRole => _activeRole;

  void switchRole(UserRole role) {
    _activeRole = role;
    notifyListeners();
  }

  Future<void> checkAuthState() async {
    _isLoggedIn = _storage.isLoggedIn;
    if (_isLoggedIn) {
      _currentUser = await _userRepo.getCurrentUser();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    try {
      final user = await _userRepo.login(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        _storage.isLoggedIn = true;
        _storage.userId = user.id;
        _setState(AuthState.success);
        return true;
      }
      _errorMessage = 'Email atau password salah';
      _setState(AuthState.error);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    List<String> interests,
  ) async {
    _setState(AuthState.loading);
    try {
      final user = await _userRepo.register(name, email, password, interests);
      _currentUser = user;
      _isLoggedIn = true;
      _storage.isLoggedIn = true;
      _storage.userId = user.id;
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = 'Pendaftaran gagal. Coba lagi.';
      _setState(AuthState.error);
      return false;
    }
  }

  Future<void> logout() async {
    await _userRepo.logout();
    _currentUser = null;
    _isLoggedIn = false;
    _storage.isLoggedIn = false;
    _storage.userId = null;
    _storage.authToken = null;
    _setState(AuthState.initial);
  }

  Future<void> updateProfile(UserModel user) async {
    _setState(AuthState.loading);
    try {
      final updated = await _userRepo.updateProfile(user);
      _currentUser = updated;
      _setState(AuthState.success);
    } catch (e) {
      _errorMessage = 'Update profil gagal';
      _setState(AuthState.error);
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) _state = AuthState.initial;
    notifyListeners();
  }
}
