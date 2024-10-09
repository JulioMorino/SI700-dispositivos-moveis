import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../model/note.dart';

class GenericCrudProvider {
  static GenericCrudProvider helper = GenericCrudProvider._createInstance();
  Dio _dio = Dio(); 

  GenericCrudProvider._createInstance() {
    
  }

/*
  Map<String, Note> database = {};
  Future<Note> getNote(String noteId) async {}
  Future<String> insertNote(Note note) async {}
  Future<String> updateNote(String noteId, Note note) async {}
  Future<String> deleteNote(String noteId) async {}
  Future<List<Note>> getNoteList() async {}
*/

  Map<String, Note> database = {
    "a": Note.withData(
      title: "Primeiro Elemento",
      description: "Primeira Descrição",
      noteId: "a",
    ),
    "b": Note.withData(
        title: "Segundo Elemento",
        description: "Segunda Descrição",
        noteId: "b"),
  };
  int numInsertions = 0;

  Future<Note> getNote(String noteId) async {
    return database[noteId] ?? Note.withData(title: "Não existe no BD");
  }

  Future<String> insertNote(Note note) async {
    _dio.post('https://aula09-notes-default-rtdb.firebaseio.com/.json', data: note.toMap());

    // String key = numInsertions.toString();
    // note.noteId = key;
    // database[key] = note;
    // numInsertions++;
    _controller.sink.add('1');
    return '1';
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

  /*
    Parte da Stream
  */
  final _random = Random();
  final StreamController _controller = StreamController();
  final _count = 0;

  final List<String> respostas = [
    "Olá, como vai você?",
    "Como posso lhe ajudar hoje?",
    "Como você está se sentindo?",
    "Qual o seu nome?",
    "Vamos nos conhecer melhor?"
  ];

  Stream get stream {
    return _controller.stream;
  }
}
