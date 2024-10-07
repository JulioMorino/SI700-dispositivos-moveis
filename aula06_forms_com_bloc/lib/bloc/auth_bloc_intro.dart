import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBlocIntro extends Bloc<AuthEvent, AuthState> {
  AuthBlocIntro() : super(Unauthenticated()) {
    on<RegisterUser>((event, emit) => null);
    on<LoginUser>((event, emit) {
      if (event.senha == 'senha') {
        emit(Authenticated(username: event.username));
      } else {
        emit(AuthError(message: "Impossivel logar com $event.username"));
      }
    });
    on<Logout>((event, emit) => emit(Unauthenticated()));
  }
}

class Authenticated extends AuthState {
  String username;

  Authenticated({required this.username});
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  String message;

  AuthError({required this.message});
}

abstract class AuthState {}

abstract class AuthEvent {}

class LoginUser extends AuthEvent {
  String username;
  String senha;

  LoginUser({required this.username, required this.senha});

  verifica() {
    if (senha == "senha") {
      return true;
    }
  }
}

class RegisterUser extends AuthEvent {
  String username;
  String senha;

  RegisterUser({required this.username, required this.senha});
}

class Logout extends AuthEvent {}
