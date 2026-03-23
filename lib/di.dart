import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/data/sources/remote/auth_api.dart';
import 'package:project_tetholiday/data/repositories/auth_repository.dart';
import 'package:project_tetholiday/data/repositories/recipe_repository.dart';
import 'package:project_tetholiday/data/repositories/feast_repository.dart';
import 'package:project_tetholiday/data/repositories/tip_repository.dart';
import 'package:project_tetholiday/data/repositories/fortune_repository.dart';
import 'package:project_tetholiday/domain/repositories/iauth_repository.dart';
import 'package:project_tetholiday/domain/repositories/irecipe_repository.dart';
import 'package:project_tetholiday/domain/repositories/ifeast_repository.dart';
import 'package:project_tetholiday/domain/repositories/itip_repository.dart';
import 'package:project_tetholiday/domain/repositories/ifortune_repository.dart';
import 'package:project_tetholiday/domain/repositories/isettings_repository.dart';
import 'package:project_tetholiday/data/repositories/settings_repository.dart';
import 'package:project_tetholiday/viewmodels/login/login_viewmodel.dart';

/// Dependency Injection: tạo và cung cấp các dependency (API, Repository, ViewModel).
class Di {
  static final AuthApi authApi = AuthApi();
  
  static final IAuthRepository authRepository = AuthRepository(authApi);
  static final IRecipeRepository recipeRepository = RecipeRepository(AppDatabase.instance);
  static final IFeastRepository feastRepository = FeastRepository(AppDatabase.instance);
  static final ITipRepository tipRepository = TipRepository(AppDatabase.instance);
  static final IFortuneRepository fortuneRepository = FortuneRepository(AppDatabase.instance);
  static final ISettingsRepository settingsRepository = SettingsRepository();

  /// Khởi tạo các thành phần nền tảng (Database, v.v.)
  static Future<void> init() async {
    await AppDatabase.instance.ensureOpen();
  }

  /// Factory methods cho ViewModels
  static LoginViewModel getLoginViewModel() => LoginViewModel(authRepository);
}
