import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aula06_forms_com_bloc/bloc/auth_bloc_intro.dart';

class PrimeiraTela extends StatelessWidget {
  PrimeiraTela({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String login = "";
  String senha = "";

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de Login
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Login'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o login';
                  } else if (value.length < 3) {
                    return 'O login deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
                onSaved: (value) {
                  login = value ?? "";
                },
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  } else if (value.length < 2) {
                    return 'A senha deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                onSaved: (value) {
                  senha = value ?? "";
                },
              ),
              const SizedBox(height: 32),

              // BlocBuilder para gerenciar o estado de autenticação
              BlocBuilder<AuthBlocIntro, AuthState>(
                builder: (BuildContext context, AuthState state) {
                  if (state is Unauthenticated || state is AuthError) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botão de Login
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              BlocProvider.of<AuthBlocIntro>(context).add(
                                LoginUser(username: login, senha: senha),
                              );
                            }
                          },
                          child: const Text("Efetuar Login"),
                        ),

                        // Botão de Registro
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              BlocProvider.of<AuthBlocIntro>(context).add(
                                RegisterUser(username: login, senha: senha),
                              );
                            }
                          },
                          child: const Text("Registrar Novo Usuário"),
                        ),
                      ],
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<AuthBlocIntro>(context).add(Logout());
                      },
                      child: const Text("Deslogar"),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
