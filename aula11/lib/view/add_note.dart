import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/manage_bloc.dart';
import '../model/note.dart';

class AddNoteScreen extends StatelessWidget {
  AddNoteScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descrController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gerenciar Banco de Dados"),
      ),
      body: BlocBuilder<ManageBloc, ManageState>(
          builder: (context, ManageState state) {
        if (state is UpdateState) {
          List noteList = state.noteList;

          for (Note note1 in noteList) {
            if (note1.noteId == state.noteId) {
              titleController.text = note1.title;
              descrController.text = note1.description;
              break;
            }
          }
        }

        return Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextFormField(
              controller: descrController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            (state is UpdateState
                ? updateState(context)
                : insertState(context)),
          ],
        );
      }),
    );
  }

  Widget insertState(context) {
    return ElevatedButton(
        onPressed: () {
          BlocProvider.of<ManageBloc>(context).add(SubmitEvent(
              note: Note.withData(
                  title: titleController.text,
                  description: descrController.text)));
          titleController.text = "";
          descrController.text = "";
        },
        child: const Text("Insira no Banco"));
  }

  Widget updateState(context) {
    return Row(
      children: [
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<ManageBloc>(context).add(SubmitEvent(
                  note: Note.withData(
                      title: titleController.text,
                      description: descrController.text)));
              titleController.text = "";
              descrController.text = "";
            },
            child: const Text("Atualize no Banco")),
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<ManageBloc>(context).add(UpdateCancel());
            },
            child: const Text("Cancele Update"))
      ],
    );
  }
}
