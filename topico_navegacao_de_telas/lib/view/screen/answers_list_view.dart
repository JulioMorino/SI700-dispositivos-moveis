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
        itemBuilder: (context, index) {
          String answeredByUser =
              _getUsernameThatAnswered(context, index, answerCollection);
          return ListTile(
            onTap: () {
              BlocProvider.of<ManageBloc>(context).add(
                  UpdateRecord(answerId: answerCollection.getIdAtIndex(index)));
              Navigator.pushNamed(context, '/create');
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                BlocProvider.of<ManageBloc>(context).add(DeleteRecord(
                    answerId: answerCollection.getIdAtIndex(index)));
              },
            ),
            leading: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 37, 26, 255),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: answeredByUser != ""
                    ? Text(
                        answeredByUser.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      )
                    : Text(""),
              ),
            ),
            title: Text('Respondido por ${answeredByUser}'),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
      );
    });
  }

  String _getUsernameThatAnswered(
      BuildContext context, int index, AnswerCollection answerCollection) {
    String answeredByUser =
        answerCollection.answerList[index].getAnswer(0).toString();
    int nameLength = answeredByUser.length;

    return answeredByUser.substring(1, nameLength - 1);
  }
}
