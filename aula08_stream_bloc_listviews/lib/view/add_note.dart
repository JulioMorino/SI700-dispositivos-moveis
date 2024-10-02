import 'package:aula08_stream_bloc_listviews/bloc/manage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note.dart';

class AddNote extends StatelessWidget {
  const AddNote({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descrController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciando o Banco de Dados'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<ManageBloc, ManageState>(
          builder: (BuildContext context, ManageState state) {
        if (state is UpdateState) {
          String noteIdVerify = state.noteId;
          List<Note> noteList = state.noteList;

          noteList.forEach((note) {
            if (note.noteId == noteIdVerify) {
              titleController.text = note.title;
              descrController.text = note.description;
            }
          });
        }
        return Column(children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          TextFormField(
            controller: descrController,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          state is UpdateState
              ? updateState(context, titleController, descrController)
              : insertState(context, titleController, descrController),
        ]);
      }),
    );
  }

  Widget insertState(
      BuildContext context,
      TextEditingController titleController,
      TextEditingController descrController) {
    return ElevatedButton(
        onPressed: () {
          BlocProvider.of<ManageBloc>(context).add(SubmitEvent(
              note: Note.withData(
                  title: titleController.text,
                  description: descrController.text)));
          titleController.text = '';
          descrController.text = '';
        },
        child: const Text('Inserir no Banco'));
  }

  Widget updateState(
      BuildContext context,
      TextEditingController titleController,
      TextEditingController descrController) {
    return Column(children: [
      ElevatedButton(
          onPressed: () {
            BlocProvider.of<ManageBloc>(context).add(SubmitEvent(
                note: Note.withData(
                    title: titleController.text,
                    description: descrController.text)));
            titleController.text = '';
            descrController.text = '';
            Navigator.pop(context);
          },
          child: const Text('Atualizar')),
      ElevatedButton(
          onPressed: () {
            BlocProvider.of<ManageBloc>(context).add(UpdateCancel());
            Navigator.pop(context);
          },
          child: const Text('Cancelar')),
    ]);
  }
}
