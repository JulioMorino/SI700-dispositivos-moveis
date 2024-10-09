import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view/autenticacao.dart';
import '../bloc/auth_bloc.dart';

import 'list_note.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<StatefulWidget> createState() {
    return WrapperState();
  }
}

class WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Erro de Autenticação"),
                  content: Text(state.message),
                );
              });
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return const ListNoteScreen();
        } else {
          return const AuthenticationScreen();
        }
      },
    );
  }
}
