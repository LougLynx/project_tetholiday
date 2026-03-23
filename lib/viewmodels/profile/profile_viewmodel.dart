import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/auth_session.dart';

class ProfileViewModel extends ChangeNotifier {
  AuthSession? _session;
  bool _isLoading = true;
  String _displayName = '';

  AuthSession? get session => _session;
  bool get isLoading => _isLoading;
  String get displayName => _displayName;

  ProfileViewModel() {
    loadSession();
  }

  void loadSession() {
    _isLoading = true;
    notifyListeners();

    final session = Di.authRepository.currentSession;
    _session = session;
    
    if (session != null) {
      _displayName = session.user.name ?? '';
      if (_displayName.isEmpty && session.user.email.isNotEmpty) {
        _displayName = session.user.email.split('@').first;
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    
    Di.authRepository.updateDisplayName(trimmed);
    _displayName = trimmed;
    notifyListeners();
  }

  Future<void> changePassword(String currentPass, String newPass, String confirmPass) async {
    if (newPass != confirmPass) {
      throw Exception('Mật khẩu mới không trùng khớp');
    }
    if (newPass.length < 6) {
      throw Exception('Mật khẩu mới tối thiểu 6 ký tự');
    }
    // TODO: gọi API đổi mật khẩu khi có backend
  }

  Future<void> logout() async {
    await Di.authRepository.logout();
  }
}
