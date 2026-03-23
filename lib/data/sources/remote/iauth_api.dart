import 'package:project_tetholiday/data/dtos/login/login_reponse_dto.dart';
import 'package:project_tetholiday/data/dtos/login/login_request_dto.dart';

/// Interface cho API xác thực (login, logout, refresh...).
abstract class IAuthApi {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<LoginResponseDto> register({
    required String username,
    required String password,
    required String displayName,
  });
}
