import 'package:project_tetholiday/data/dtos/login/login_request_dto.dart';
import 'package:project_tetholiday/domain/entities/auth_session.dart';
import 'package:project_tetholiday/domain/entities/user.dart';
import 'package:project_tetholiday/implementations/api/auth_api.dart';
import 'package:project_tetholiday/interfaces/repositories/iauth_repository.dart';

/// Implementation của IAuthRepository.
class AuthRepository implements IAuthRepository {
  AuthRepository(this._authApi);

  final AuthApi _authApi;
  AuthSession? _currentSession;

  @override
  Future<AuthSession?> login(String email, String password) async {
    final dto = await _authApi.login(
      LoginRequestDto(email: email, password: password),
    );
    _currentSession = AuthSession(
      token: dto.token,
      user: User(
        id: dto.user.id,
        email: dto.user.email,
        name: dto.user.name,
      ),
    );
    return _currentSession;
  }

  @override
  Future<void> logout() async {
    _currentSession = null;
  }

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  void updateDisplayName(String name) {
    if (_currentSession == null) return;
    final u = _currentSession!.user;
    _currentSession = AuthSession(
      token: _currentSession!.token,
      user: User(id: u.id, email: u.email, name: name),
    );
  }
}
