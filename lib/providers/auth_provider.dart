import 'package:flutter/material.dart';
import '../core/storage/local_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String get userRole => _user?.role ?? 'student';

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    final token = LocalStorage.getToken();
    final cachedUser = LocalStorage.getUser();

    if (token == null || token.isEmpty) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }

    if (!LocalStorage.getRememberMe()) {
      await LocalStorage.clearToken();
      await LocalStorage.clearUser();
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }

    if (cachedUser != null) {
      _user = UserModel.fromJson(cachedUser);
    }

    try {
      final freshUser = await _authService.getProfile();
      _user = freshUser;
      _status = AuthStatus.authenticated;
    } catch (_) {
      // If fetching fails but token exists, and token expired:
      if (token.isEmpty) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        // Fallback to cached profile if network issue
        if (_user != null) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password, {bool rememberMe = true}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(identifier, password, rememberMe: rememberMe);
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void forceLogout() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = 'Your session has expired. Please log in again.';
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
