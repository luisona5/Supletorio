import 'package:get_it/get_it.dart';

// Auth
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Reportes
import '../../features/reportes/data/datasources/reporte_datasource.dart';
import '../../features/reportes/data/repositories/reporte_repository_impl.dart';
import '../../features/reportes/domain/repositories/reporte_repository.dart';
import '../../features/reportes/domain/usecases/create_reporte_usecase.dart';
import '../../features/reportes/domain/usecases/get_reportes_usecase.dart';
import '../../features/reportes/domain/usecases/update_reporte_usecase.dart';
import '../../features/reportes/domain/usecases/delete_reporte_usecase.dart';
import '../../features/reportes/presentation/bloc/reporte_bloc.dart';

/// Service Locator (Inyección de Dependencias)
final sl = GetIt.instance;

/// Inicializar todas las dependencias
Future<void> initializeDependencies() async {
  // ========== AUTH - BLOCS ==========
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // ========== AUTH - USE CASES ==========
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ========== AUTH - REPOSITORIES ==========
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // ========== AUTH - DATA SOURCES ==========
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(),
  );

  // ========== REPORTES - BLOCS ==========
  sl.registerFactory(
    () => ReporteBloc(
      createReporteUseCase: sl(),
      getMyReportesUseCase: sl(),
      getAllReportesUseCase: sl(),
      getReportesByEstadoUseCase: sl(),
      updateReporteUseCase: sl(),
      updateEstadoReporteUseCase: sl(),
      deleteReporteUseCase: sl(),
    ),
  );

  // ========== REPORTES - USE CASES ==========
  sl.registerLazySingleton(() => CreateReporteUseCase(sl()));
  sl.registerLazySingleton(() => GetMyReportesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllReportesUseCase(sl()));
  sl.registerLazySingleton(() => GetReportesByEstadoUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReporteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEstadoReporteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReporteUseCase(sl()));

  // ========== REPORTES - REPOSITORIES ==========
  sl.registerLazySingleton<ReporteRepository>(
    () => ReporteRepositoryImpl(sl()),
  );

  // ========== REPORTES - DATA SOURCES ==========
  sl.registerLazySingleton<ReporteDataSource>(
    () => ReporteDataSourceImpl(),
  );

  print('✅ Dependencias inicializadas correctamente');
}
