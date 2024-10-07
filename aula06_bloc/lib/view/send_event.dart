import 'package:aula06_bloc/bloc/red_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendEvent extends StatelessWidget {
  const SendEvent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //context esta relacionado ao SendEvent na widget tree
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<RedBloc>(context).add(SemRed());
            },
            child: const Text("Sem")),
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<RedBloc>(context).add(PoucoRed());
            },
            child: const Text("Pouco")),
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<RedBloc>(context).add(NormalRed());
            },
            child: const Text("Normal")),
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<RedBloc>(context).add(MuitoRed());
            },
            child: const Text("Muito")),
      ],
    );
  }
}
