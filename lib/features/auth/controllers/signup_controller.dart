import 'package:flutter_riverpod/legacy.dart';
import 'package:season_app/features/auth/data/repositories/auth_repository.dart';

class SignupState {
  final bool isLoading;
  final String? error;
  final String? message;

  SignupState({
    this.isLoading = false,
    this.error,
    this.message,
  });

  SignupState copyWith({
    bool? isLoading,
    String? error,
    String? message,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
    );
  }
}

class SignupController extends StateNotifier<SignupState> {
  final AuthRepository repository;

  SignupController(this.repository) : super(SignupState());

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? notificationToken,
  }) async {
    state = state.copyWith(isLoading: true, error: null, message: null);

    try {
      final message = await repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        notificationToken: notificationToken,
      );

      state = state.copyWith(isLoading: false, message: message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}
