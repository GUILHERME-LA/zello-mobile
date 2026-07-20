import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

enum LoginRole { patient, professional }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  LoginRole _selectedRole = LoginRole.patient;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == ZelloAuthStatus.loading;
    final isProfessional = _selectedRole == LoginRole.professional;

    ref.listen<ZelloAuthState>(authProvider, (prev, next) {
      if (next.status == ZelloAuthStatus.authenticated) {
        final isAdminOrProf =
            next.user?.isAdmin == true || next.user?.isProfessional == true;
        if (mounted) {
          context.go(isAdminOrProf ? '/admin/dashboard' : '/home');
        }
      } else if (next.status == ZelloAuthStatus.error && next.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: ZelloColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ZelloGradients.screenBackground,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: ZelloGradients.avatar,
                            shape: BoxShape.circle,
                            boxShadow: ZelloShadows.accent(ZelloColors.primary),
                          ),
                          child: Icon(
                            isProfessional
                                ? Icons.admin_panel_settings
                                : Icons.local_hospital,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Zello Saúde',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: ZelloColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isProfessional
                              ? 'Painel Administrativo'
                              : 'Acesse sua conta',
                          style: TextStyle(
                            fontSize: 14,
                            color: ZelloColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Role toggle
                        Container(
                          decoration: BoxDecoration(
                            color: ZelloColors.surfaceLighter,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedRole = LoginRole.patient),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isProfessional
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: !isProfessional
                                          ? ZelloShadows.xs
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 18,
                                          color: !isProfessional
                                              ? ZelloColors.primary
                                              : ZelloColors.textTertiary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Paciente',
                                          style: TextStyle(
                                            fontWeight: !isProfessional
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: !isProfessional
                                                ? ZelloColors.primary
                                                : ZelloColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() =>
                                      _selectedRole = LoginRole.professional),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isProfessional
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: isProfessional
                                          ? ZelloShadows.xs
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.medical_services,
                                          size: 18,
                                          color: isProfessional
                                              ? ZelloColors.primary
                                              : ZelloColors.textTertiary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Profissional',
                                          style: TextStyle(
                                            fontWeight: isProfessional
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isProfessional
                                                ? ZelloColors.primary
                                                : ZelloColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe seu email';
                            }
                            if (!v.contains('@')) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Informe sua senha' : null,
                        ),
                        const SizedBox(height: 4),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/forgot-password'),
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(
                                color: ZelloColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        // Sign up link (only for patient)
                        if (!isProfessional) ...[
                          const SizedBox(height: 4),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/signup'),
                              child: const Text(
                                'Criar conta',
                                style: TextStyle(
                                  color: ZelloColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Error message
                        if (authState.status == ZelloAuthStatus.error)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              authState.error!,
                              style: TextStyle(
                                color: ZelloColors.danger,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ZelloColors.primary,
                              foregroundColor: ZelloColors.textOnPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Entrar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'Ao entrar, você concorda com nossos Termos de Uso.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: ZelloColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
