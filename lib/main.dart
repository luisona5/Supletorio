import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import '../core/di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/shared/widgets/loading_widget.dart';
import 'features/shared/widgets/splash_screen.dart';
import 'features/reportes/presentation/pages/ciudadano_home_page.dart';
import 'features/reportes/presentation/pages/admin_home_page.dart';
import 'features/reportes/presentation/bloc/reporte_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar Supabase
  await SupabaseClientManager.initialize();

  // Inicializar dependencias
  await initializeDependencies();

  runApp(const ElVeciReportaApp());
}

class ElVeciReportaApp extends StatelessWidget {
  const ElVeciReportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => sl<ReporteBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper que maneja la navegación según el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Loading - Mostrar Splash
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        // Autenticado - Redirigir según rol
        if (state is AuthAuthenticated) {
          return _HomePageForUser(user: state.user);
        }

        // No autenticado - Ir a Login
        return const LoginPage();
      },
    );
  }
}

/// Página según el tipo de usuario
class _HomePageForUser extends StatelessWidget {
  final User user;

  const _HomePageForUser({required this.user});

  @override
  Widget build(BuildContext context) {
    // Redirigir según el rol
    if (user.isAdministrador) {
      return const AdminHomePage();
    } else {
      return const CiudadanoHomePage();
    }
  }
}