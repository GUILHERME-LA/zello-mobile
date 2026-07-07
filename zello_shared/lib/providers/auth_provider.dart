import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../core/api/api_client.dart';
import '../core/demo_data.dart';
import '../models/user.dart';
import 'api_client_provider.dart';

enum ZelloAuthStatus { initial, loading, authenticated, unauthenticated, error }

class ZelloAuthState {
  final ZelloAuthStatus status;
  final User? user;
  final String? error;
  final String? message;

  const ZelloAuthState({
    this.status = ZelloAuthStatus.initial,
    this.user,
    this.error,
    this.message,
  });

  bool get isAdmin => user?.isAdmin == true;
  bool get isProfessional => user?.isProfessional == true;
  bool get isPatient => user?.isPatient == true;
}

class AuthNotifier extends StateNotifier<ZelloAuthState> {
  final ApiClient _api;
  final SupabaseClient _supabase;
  late final StreamSubscription<AuthState> _authSub;

  AuthNotifier(this._api, this._supabase) : super(const ZelloAuthState()) {
    _authSub = _supabase.auth.onAuthStateChange.listen(_onAuthChange);
  }

  Future<void> _loadProfile(User baseUser) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('id, role')
          .eq('user_id', baseUser.id)
          .maybeSingle();
      if (profile != null) {
        final role = UserRole.values.firstWhere(
          (e) => e.name == profile['role'],
          orElse: () => UserRole.patient,
        );
        final profileId = profile['id'] as String?;

        String? professionalId;
        if (role == UserRole.professional && profileId != null) {
          final profRecord = await _supabase
              .from('professionals')
              .select('id')
              .eq('profile_id', profileId)
              .maybeSingle();
          professionalId = profRecord?['id'] as String?;
        }

        final enrichedUser = baseUser.copyWith(
          role: role,
          profileId: profileId,
          professionalId: professionalId,
        );
        state = ZelloAuthState(status: ZelloAuthStatus.authenticated, user: enrichedUser);
        return;
      }
    } catch (_) {}
    state = ZelloAuthState(status: ZelloAuthStatus.authenticated, user: baseUser);
  }

  void _onAuthChange(AuthState authState) {
    final session = authState.session;
    if (authState.event == AuthChangeEvent.signedIn && session != null) {
      final meta = session.user.userMetadata ?? {};
      final baseUser = User(
        id: session.user.id,
        name: meta['name'] as String? ?? session.user.email?.split('@').first ?? '',
        email: session.user.email ?? '',
        phone: meta['phone'] as String? ?? '',
        token: session.accessToken,
      );
      _api.loadCurrentPatient(baseUser.id);
      _loadProfile(baseUser);
    } else if (authState.event == AuthChangeEvent.signedOut) {
      _api.clearPatientContext();
      state = const ZelloAuthState(status: ZelloAuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = const ZelloAuthState(status: ZelloAuthStatus.loading);
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      state = ZelloAuthState(status: ZelloAuthStatus.error, error: e.toString());
    }
  }

  Future<void> demoLogin() async {
    _api.enableDemo();
    state = const ZelloAuthState(status: ZelloAuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 500));
    state = ZelloAuthState(status: ZelloAuthStatus.authenticated, user: demoUser);
  }

  Future<void> signUp(String email, String password, {String? name, String? phone}) async {
    state = const ZelloAuthState(status: ZelloAuthStatus.loading);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      final userId = response.user?.id;
      if (userId != null) {
        await _supabase.from('profiles').insert({
          'user_id': userId,
          'role': 'patient',
          'name': name ?? email.split('@').first,
          'email': email,
          'phone': phone ?? '',
        }).select('id').single();
        await _supabase.from('patients').insert({
          'user_id': userId,
          'name': name ?? email.split('@').first,
          'email': email,
          'phone': phone ?? '',
        });
      }

      if (response.session != null) {
        state = const ZelloAuthState(
          status: ZelloAuthStatus.authenticated,
        );
      } else {
        state = ZelloAuthState(
          status: ZelloAuthStatus.unauthenticated,
          message: 'Cadastro realizado! Verifique seu email para confirmar a conta.',
        );
      }
    } catch (e) {
      state = ZelloAuthState(status: ZelloAuthStatus.error, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    state = const ZelloAuthState(status: ZelloAuthStatus.loading);
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      state = ZelloAuthState(
        status: ZelloAuthStatus.unauthenticated,
        message: 'Enviamos um link de recuperação para $email',
      );
    } catch (e) {
      state = ZelloAuthState(status: ZelloAuthStatus.error, error: e.toString());
    }
  }

  Future<void> changePassword(String newPassword) async {
    state = const ZelloAuthState(status: ZelloAuthStatus.loading);
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      state = ZelloAuthState(
        status: ZelloAuthStatus.authenticated,
        user: state.user,
        message: 'Senha alterada com sucesso',
      );
    } catch (e) {
      state = ZelloAuthState(status: ZelloAuthStatus.error, error: e.toString());
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, ZelloAuthState>((ref) {
  final supabase = Supabase.instance.client;
  return AuthNotifier(ref.read(apiClientProvider), supabase);
});
