import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/shared/widgets/loading_widget.dart';

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
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
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
        // Loading
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: LoadingWidget(message: 'Verificando autenticación...'),
          );
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

/// Página temporal según el tipo de usuario
/// 
/// Será reemplazada por las páginas reales en la siguiente fase
class _HomePageForUser extends StatelessWidget {
  final User user;

  const _HomePageForUser({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.isAdministrador
            ? 'Panel Administrador'
            : 'Mis Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                user.isAdministrador
                    ? Icons.admin_panel_settings
                    : Icons.person,
                size: 80,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                '¡Bienvenido!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: user.isAdministrador
                      ? AppTheme.secondary.withOpacity(0.1)
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.userType.displayName,
                  style: TextStyle(
                    color: user.isAdministrador
                        ? AppTheme.secondary
                        : AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: 40,
                        color: AppTheme.warning,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Fase 2 Completada ✅',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Autenticación y diferenciación de roles funcionando correctamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Próximo paso: Implementar sistema de reportes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}