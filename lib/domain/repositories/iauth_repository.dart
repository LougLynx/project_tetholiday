import 'package:project_tetholiday/domain/entities/auth_session.dart';

/// Interface cho repository xác thực.
abstract class IAuthRepository {
  Future<AuthSession?> login(String email, String password);
  Future<AuthSession?> register({
    required String username,
    required String password,
    required String displayName,
  });
  Future<void> logout();
  AuthSession? get currentSession;
  void updateDisplayName(String name);
}
