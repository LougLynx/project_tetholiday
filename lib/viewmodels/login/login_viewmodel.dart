import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/domain/entities/auth_session.dart';
import 'package:project_tetholiday/domain/repositories/iauth_repository.dart';

/// ViewModel dùng chung cho Login và Register.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final IAuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  AuthSession? _session;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthSession? get session => _session;

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _session = await _authRepository.login(username, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _session = await _authRepository.register(
        username: username,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
