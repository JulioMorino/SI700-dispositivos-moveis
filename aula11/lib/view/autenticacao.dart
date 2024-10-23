import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String login = "";
  String senha = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Autenticação de Usuário"),
      ),
      body: Center(
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(label: Text("Login")),
                  onSaved: (String? newValue) {
                    login = newValue ?? "";
                  },
                  validator: (String? value) {
                    if (value != null) {
                      if (value.length < 3) {
                        return "Erro: Não existe login de três letras";
                      } else {
                        return null;
                      }
                    } else {
                      return "Erro: Insira seu login";
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Senha")),
                  onSaved: (String? newValue) {
                    senha = newValue ?? "";
                  },
                  validator: (String? value) {
                    if (value != null) {
                      if (value.length < 3) {
                        return "Erro: Não existe senha de três letras";
                      } else {
                        return null;
                      }
                    } else {
                      return "Erro: Insira sua senha";
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              BlocProvider.of<AuthBloc>(context).add(LoginUser(
                                username: login,
                                password: senha,
                              ));
                            }
                          },
                          child: const Text("Efetuar Login")),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              BlocProvider.of<AuthBloc>(context)
                                  .add(RegisterUser(
                                username: login,
                                password: senha,
                              ));
                            }
                          },
                          child: const Text("Registrar Novo Usuário"))
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
