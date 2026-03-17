import 'package:project_tetholiday/data/dtos/login/login_reponse_dto.dart';
import 'package:project_tetholiday/data/dtos/login/login_request_dto.dart';
import 'package:project_tetholiday/data/dtos/login/user_dto.dart';
import 'package:project_tetholiday/interfaces/api/iauth_api.dart';

/// Implementation của IAuthApi (mock: admin/admin).
class AuthApi implements IAuthApi {
  static const String _defaultUser = 'admin';
  static const String _defaultPassword = 'admin';

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final email = request.email.trim().toLowerCase();
    final password = request.password;
    if (email == _defaultUser && password == _defaultPassword) {
      return LoginResponseDto(
        token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
        user: UserDto(
          id: '1',
          email: email,
          name: 'Quản trị viên',
        ),
      );
    }
    throw Exception('Tên đăng nhập hoặc mật khẩu không đúng.');
  }
}
