

import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note.dart';
import '../provider/generic_crud_provider.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  ManageBloc(super.initialState) {
    GenericCrudProvider.helper.stream.listen((noteId) {
      // Precisaria no futuro ser repensado
      add(GetNoteListEvent());
    });

    on<DeleteEvent>((event, emit) {
      GenericCrudProvider.helper.deleteNote(event.noteId);
    });

    on<UpdateRequest>(
      (event, emit) {
        emit(
          UpdateState(
            noteId: event.noteId,
            noteList: state.noteList,
          ),
        );
      },
    );

    on<UpdateCancel>(
      (event, emit) {
        emit(InsertState(
          noteList: state.noteList,
        ));
      },
    );

    on<SubmitEvent>(
      (event, emit) {
        if (state is UpdateState) {
          GenericCrudProvider.helper
              .updateNote((state as UpdateState).noteId, event.note);

          emit(InsertState(noteList: state.noteList));
        } else if (state is InsertState) {
          GenericCrudProvider.helper.insertNote(event.note);
        }
      },
    );

    on<GetNoteListEvent>((event, emit) async {
      List<Note> noteList = await GenericCrudProvider.helper.getNoteList();

      if (state is UpdateState) {
        emit(UpdateState(
          noteId: (state as UpdateState).noteId,
          noteList: noteList,
        ));
      } else if (state is InsertState) {
        emit(InsertState(
          noteList: noteList,
        ));
      }
    });
  }
}

/*
 Eventos
*/
abstract class ManageEvent {}

class SubmitEvent extends ManageEvent {
  Note note;
  SubmitEvent({required this.note});
}

class DeleteEvent extends ManageEvent {
  String noteId;
  DeleteEvent({required this.noteId});
}

class GetNoteListEvent extends ManageEvent {}

class UpdateRequest extends ManageEvent {
  String noteId;
  UpdateRequest({required this.noteId});
}

class UpdateCancel extends ManageEvent {}

/*
 Estados
*/
abstract class ManageState {
  List<Note> noteList;
  ManageState({required this.noteList});
}

class InsertState extends ManageState {
  InsertState({required super.noteList});
}

class UpdateState extends ManageState {
  String noteId;

  UpdateState({
    required this.noteId,
    required super.noteList,
  });
}
