import 'package:aula08_stream_bloc_listviews/bloc/manage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note.dart';

class ListNote extends StatelessWidget {
  const ListNote({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageBloc, ManageState>(
      builder: (BuildContext context, ManageState state) {
        List<Note> noteList = state.noteList;
        return ListView.builder(
          itemCount: noteList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                BlocProvider.of<ManageBloc>(context)
                    .add(UpdateRequest(noteId: noteList[index].noteId));
              },
              title: Text(noteList[index].title),
              subtitle: Text(noteList[index].description),
              trailing: IconButton(
                onPressed: () {
                  BlocProvider.of<ManageBloc>(context)
                      .add(DeleteEvent(noteId: noteList[index].noteId));
                },
                icon: Icon(Icons.delete),
              ),
            );
          },
        );
      },
    );
  }
}
