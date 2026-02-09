import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'select_user_type_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserType _selectedUserType = UserType.ciudadano;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectUserType() async {
    final result = await Navigator.of(context).push<UserType>(
      MaterialPageRoute(
        builder: (_) => const SelectUserTypePage(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedUserType = result;
      });
    }
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          RegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            userType: _selectedUserType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Creando cuenta...',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Crear Cuenta',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Únete a ${AppStrings.appName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 32),

                      // Tipo de usuario
                      InkWell(
                        onTap: _selectUserType,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedUserType == UserType.ciudadano
                                    ? Icons.person_outline
                                    : Icons.admin_panel_settings_outlined,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tipo de cuenta',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                    Text(
                                      _selectedUserType.displayName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppTheme.textGrey,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Nombre completo
                      CustomTextField(
                        label: AppStrings.fullName,
                        hint: 'Juan Pérez',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        validator: Validators.fullName, hintText: '',
                      ),

                      const SizedBox(height: 20),

                      // Email
                      CustomTextField(
                        label: AppStrings.email,
                        hint: 'tu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.email, hintText: '',
                      ),

                      const SizedBox(height: 20),

                      // Contraseña
                      CustomTextField(
                        label: AppStrings.password,
                        hint: '••••••••',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: Validators.password, hintText: '',
                      ),

                      const SizedBox(height: 20),

                      // Confirmar contraseña
                      CustomTextField(
                        label: 'CONFIRMAR CONTRASEÑA',
                        hint: '••••••••',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirma tu contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        }, hintText: '',
                      ),

                      const SizedBox(height: 32),

                      // Botón registrarse
                      CustomButton(
                        text: 'Crear Cuenta',
                        onPressed: isLoading ? null : _handleRegister,
                        isLoading: isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Ya tienes cuenta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${AppStrings.haveAccount} ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              AppStrings.login,
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}