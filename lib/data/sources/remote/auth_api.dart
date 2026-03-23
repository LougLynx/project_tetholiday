import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/data/dtos/login/login_reponse_dto.dart';
import 'package:project_tetholiday/data/dtos/login/login_request_dto.dart';
import 'package:project_tetholiday/data/dtos/login/user_dto.dart';
import 'package:project_tetholiday/data/sources/remote/iauth_api.dart';

/// Implementation của IAuthApi — dùng SQLite thay cho hardcode.
class AuthApi implements IAuthApi {
  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final row = await AppDatabase.instance.loginUser(
      request.email,
      request.password,
    );
    if (row == null) {
      throw Exception('Tên đăng nhập hoặc mật khẩu không đúng.');
    }
    return LoginResponseDto(
      token: 'token-${row['id']}-${DateTime.now().millisecondsSinceEpoch}',
      user: UserDto(
        id: '${row['id']}',
        email: row['username'] as String,
        name: row['display_name'] as String? ?? '',
      ),
    );
  }

  @override
  Future<LoginResponseDto> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final id = await AppDatabase.instance.registerUser(
      username: username,
      password: password,
      displayName: displayName,
    );
    return LoginResponseDto(
      token: 'token-$id-${DateTime.now().millisecondsSinceEpoch}',
      user: UserDto(
        id: '$id',
        email: username.trim().toLowerCase(),
        name: displayName.trim(),
      ),
    );
  }
}
