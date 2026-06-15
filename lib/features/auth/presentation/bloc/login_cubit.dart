import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/usecases/login_use_case.dart';
import 'login_state.dart';

class LoginCubit extends SafeCubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(const LoginInitial());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (state is LoginSubmitting) {
      return;
    }

    safeEmit(const LoginSubmitting());
    final result = await _loginUseCase(
      LoginCredentials(username: username, password: password),
    );

    switch (result) {
      case ApiSuccess<AuthSession>(data: final session):
        safeEmit(LoginSuccess(session));
      case ApiFailure<AuthSession>(failure: final failure):
        safeEmit(LoginFailure(failure));
    }
  }
}
