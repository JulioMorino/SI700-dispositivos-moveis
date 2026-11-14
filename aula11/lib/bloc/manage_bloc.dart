import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note.dart';
import '../provider/generic_crud_provider.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  // Guardamos a assinatura para poder cancelá-la e assinar de novo quando o
  // uid mudar (login/logout). O caminho do stream depende do uid
  // (notes/{uid}/my_notes), e ele é calculado no momento do listen.
  StreamSubscription? _noteSubscription;

  ManageBloc(super.initialState) {
    on<SubscribeNoteStreamEvent>((event, emit) async {
      await _noteSubscription?.cancel();
      _noteSubscription = GenericCrudProvider.helper.stream.listen((noteList) {
        add(UpdateNoteListEvent(noteList: noteList));
      });
    });

    add(SubscribeNoteStreamEvent());

    on<DeleteEvent>((event, emit) async {
      try {
        await GenericCrudProvider.helper.deleteNote(event.noteId);
      } catch (e) {
        debugPrint("Erro ao deletar no Firestore: $e");
      }
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
      (event, emit) async {
        try {
          if (state is UpdateState) {
            await GenericCrudProvider.helper
                .updateNote((state as UpdateState).noteId, event.note);

            emit(InsertState(noteList: state.noteList));
          } else if (state is InsertState) {
            await GenericCrudProvider.helper.insertNote(event.note);
          }
        } catch (e) {
          // Antes o erro sumia em silêncio. Agora ele aparece no console.
          debugPrint("Erro ao gravar no Firestore: $e");
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

    on<UpdateNoteListEvent>((event, emit) async {
      List<Note> noteList = event.noteList;

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

  @override
  Future<void> close() async {
    await _noteSubscription?.cancel();
    return super.close();
  }
}

/*
 Eventos
*/

// Reassina o stream do Firestore com o uid atual do GenericCrudProvider.
class SubscribeNoteStreamEvent extends ManageEvent {}

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

class UpdateNoteListEvent extends ManageEvent {
  List<Note> noteList;

  UpdateNoteListEvent({required this.noteList});
}

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
