import 'dart:async';

import '../model/note.dart';

class GenericCrudProvider {
  static GenericCrudProvider helper = GenericCrudProvider._createInstance();

  GenericCrudProvider._createInstance();

  Map<String, Note> database = {
    "a": Note.withData(
        title: 'Deu certo',
        description: 'Isto é uma descrição......',
        noteId: 'a'),
    "b": Note.withData(
        title: 'Deu certo 2',
        description: 'Isto é uma segunda descrição.',
        noteId: 'b')
  };
  int numInsertions = 0; //incrementador de IDs

  Future<Note> getNote(String noteId) async {
    return database[noteId] ?? Note.withData(title: 'Não existe no banco');
  }

/*Estamos retornando chave primaria para confirmar onde operacao foi feita */
  Future<String> insertNote(Note note) async {
    String key = numInsertions.toString();
    numInsertions++;

    note.noteId = key;
    database[key] = note;

    _controller.sink.add(key);
    return key;
  }

  Future<String> updateNote(String noteId, Note note) async {
    note.noteId = noteId;
    database[noteId] = note;
    _controller.sink.add(noteId);
    return noteId;
  }

  Future<String> deleteNote(String noteId) async {
    database.remove(noteId);
    _controller.sink.add(noteId);
    return noteId;
  }

  Future<List<Note>> getNoteList() async {
    return database.values.toList();
  }

  //STREAMS
  final StreamController _controller = StreamController();

  Stream get stream {
    return _controller.stream;
  }
}
