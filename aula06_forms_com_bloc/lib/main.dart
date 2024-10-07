import 'package:aula06_forms_com_bloc/bloc/auth_bloc_intro.dart';
import 'package:aula06_forms_com_bloc/view/layout/my_bottom_navigation_bar.dart';
import 'package:aula06_forms_com_bloc/view/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Flutter Stateful Clicker Counter';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) {
          return AuthBlocIntro();
        },
        child: Wrapper(),
      ),
    );
  }
}
