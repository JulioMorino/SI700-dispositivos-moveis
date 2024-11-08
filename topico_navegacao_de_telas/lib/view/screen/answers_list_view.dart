import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/answer_manager.dart';
import '../../bloc/answers_monitor.dart';
import '../../model/answer_collection.dart';

class AnswerList extends StatelessWidget {
  const AnswerList({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Registros'),
      ),
      body: _buildAnswersList(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          BlocProvider.of<ManageBloc>(context).add(CreateRecord());
          Navigator.pushNamed(context, "/create");
        },
      ),
    );
  }

  Widget _buildAnswersList() {
    return BlocBuilder<MonitorBloc, MonitorState>(builder: (context, state) {
      AnswerCollection answerCollection = state.answerCollection;
      return ListView.separated(
        itemCount: answerCollection.length(),
        itemBuilder: (context, index) => ListTile(
          title: Text('${answerCollection.getAnswerAtIndex(index)}ª resposta'),
        ),
        separatorBuilder: (_, __) => const Divider(),
      );
    });
  }
}
