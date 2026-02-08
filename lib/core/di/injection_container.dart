import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Service Locator (Inyección de Dependencias)
final sl = GetIt.instance;

/// Inicializar todas las dependencias
Future<void> initializeDependencies() async {
  // ========== BLOCS ==========
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // ========== USE CASES ==========
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ========== REPOSITORIES ==========
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // ========== DATA SOURCES ==========
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(),
  );

  print('✅ Dependencias inicializadas correctamente');
}