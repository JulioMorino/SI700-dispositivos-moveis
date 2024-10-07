import 'package:aula06_bloc/bloc/red_bloc.dart';
import 'package:aula06_bloc/view/receive_state.dart';
import 'package:aula06_bloc/view/send_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Flutter Stateful Clicker Counter';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) {
          return RedBloc(RedState(amount: 25));
        },
        child: MaterialApp(
          title: _title,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Container(
              color: Colors.orange,
              child: const Column(children: [
                SendEvent(),
                Expanded(
                  child: ReceiveState(),
                )
              ])),
        ));
  }
}
