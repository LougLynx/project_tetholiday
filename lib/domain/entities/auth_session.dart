import 'user.dart';

/// Entity phiên đăng nhập (token + user).
class AuthSession {
  final String token;
  final User user;

  const AuthSession({
    required this.token,
    required this.user,
  });
}
