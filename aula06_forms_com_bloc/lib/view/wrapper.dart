import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula06_forms_com_bloc/bloc/auth_bloc_intro.dart';
import 'package:aula06_forms_com_bloc/view/layout/my_bottom_navigation_bar.dart';
import 'package:aula06_forms_com_bloc/view/layout/my_tab_bar.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBlocIntro, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Erro de Autenticação"),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return const MyBottomNavigationBar();
        } else {
          return const MyTabLayout();
        }
      },
    );
  }
}
