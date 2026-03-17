import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/domain/entities/auth_session.dart';
import 'package:project_tetholiday/interfaces/repositories/iauth_repository.dart';

/// ViewModel cho màn Login (xử lý logic, gọi repository, expose state).
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

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authRepository.login(email, password);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
