

import 'package:aula09/bloc/auth_bloc.dart';
import 'package:aula09/bloc/manage_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/note.dart';
import 'add_note.dart';

class ListNoteScreen extends StatelessWidget {
  const ListNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Listagen dos Dados"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              BlocProvider.of<ManageBloc>(context).add(UpdateCancel());
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddNoteScreen()));
            },
            tooltip: 'Botão 1',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16), // Espaço entre os botões
          FloatingActionButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(Logout());
            },
            tooltip: 'Botão 2',
            child: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<ManageBloc, ManageState>(
        builder: (BuildContext context, ManageState state) {
          List noteList = state.noteList;
          return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, position) {
                return ListTile(
                  onTap: () {
                    BlocProvider.of<ManageBloc>(context)
                        .add(UpdateRequest(noteId: noteList[position].noteId));
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddNoteScreen()));
                  },
                  title: Text(noteList[position].title),
                  subtitle: Text(noteList[position].description),
                  trailing: GestureDetector(
                      onTap: () {
                        BlocProvider.of<ManageBloc>(context).add(
                            DeleteEvent(noteId: noteList[position].noteId));
                      },
                      child: const Icon(Icons.delete)),
                );
              });
        },
      ),
    );
  }
}
