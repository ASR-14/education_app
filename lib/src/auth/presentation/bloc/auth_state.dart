part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class SignedIn extends AuthState {
  const SignedIn({required this.user});

  final LocalUser user;

  @override
  List<Object?> get props => [user];
}

class SignedUp extends AuthState {
  const SignedUp();
}

class ForgotPasswordSent extends AuthState {
  const ForgotPasswordSent();
}

class UserUpdated extends AuthState {
  const UserUpdated();
}

class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
