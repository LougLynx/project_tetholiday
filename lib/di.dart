import 'package:project_tetholiday/implementations/api/auth_api.dart';
import 'package:project_tetholiday/implementations/repositories/auth_repository.dart';
import 'package:project_tetholiday/interfaces/repositories/iauth_repository.dart';
import 'package:project_tetholiday/viewmodels/login/login_viewmodel.dart';

/// Dependency Injection: tạo và cung cấp các dependency (API, Repository, ViewModel).
class Di {
  static final AuthApi authApi = AuthApi();
  static final IAuthRepository authRepository =
      AuthRepository(authApi);

  static LoginViewModel getLoginViewModel() =>
      LoginViewModel(authRepository);
}
