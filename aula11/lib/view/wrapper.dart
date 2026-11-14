import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view/autenticacao.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/manage_bloc.dart';

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
        // O AuthBloc já atualizou o uid do GenericCrudProvider. Avisamos o
        // ManageBloc para voltar a ouvir notes/{uid}/my_notes do usuário certo.
        if (state is Authenticated || state is Unauthenticated) {
          BlocProvider.of<ManageBloc>(context)
            ..add(SubscribeNoteStreamEvent())
            ..add(GetNoteListEvent());
        }
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
