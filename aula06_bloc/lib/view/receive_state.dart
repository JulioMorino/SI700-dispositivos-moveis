import 'package:aula06_bloc/bloc/red_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiveState extends StatelessWidget {
  const ReceiveState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //vai reagir a mudancas do RedBloc
    //
    return BlocBuilder<RedBloc, RedState>(
        builder: (BuildContext context, RedState state) {
      return Container(
        color: Color.fromRGBO(state.amount, 0, 0, 1),
      );
    });
  }
}

//reserve o BlocBuilder somente para interface grafica
