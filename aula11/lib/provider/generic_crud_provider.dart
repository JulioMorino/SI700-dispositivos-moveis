import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../model/note.dart';


class GenericCrudProvider {
  static GenericCrudProvider helper = GenericCrudProvider._createInstance();
  Dio _dio = Dio();

  final CollectionReference noteCollection =
  FirebaseFirestore.instance.collection("notes");

  String uid = "default";

  String path = 'https://aula09-notes-default-rtdb.firebaseio.com/.json';

  GenericCrudProvider._createInstance() {}

/*
  Map<String, Note> database = {};
  Future<Note> getNote(String noteId) async {}
  Future<String> insertNote(Note note) async {}
  Future<String> updateNote(String noteId, Note note) async {}
  Future<String> deleteNote(String noteId) async {}
  Future<List<Note>> getNoteList() async {}
*/

  Future<Note> getNote(String noteId) async {
    DocumentSnapshot response = await noteCollection.doc(uid).collection("my_notes").doc(noteId).get();
    
    // Response response = await _dio.get(
    //     'https://c9fbeafb-bf92-49fc-b603-f32a2c633069-00-2ilewbikzvnu8.janeway.replit.dev/notes/$noteId');
   
    Note note = Note.fromMap(response.data());
    note.noteId = noteId;
    return note;
  }

  Future<String> insertNote(Note note) async {

    noteCollection.doc(uid).collection("my_notes").add(note.toMap());


    // _dio.post(
    //     'https://c9fbeafb-bf92-49fc-b603-f32a2c633069-00-2ilewbikzvnu8.janeway.replit.dev/notes',
    //     data: note.toMap());

    // String key = numInsertions.toString();
    // note.noteId = key;
    // database[key] = note;
    // numInsertions++;
    // _controller.sink.add('1');
    return '1';
  }

  Future<String> updateNote(String noteId, Note note) async {
    
    noteCollection.doc(uid).collection("my_notes").doc(noteId).update(note.toMap());
    // _dio.put(
    //     'https://c9fbeafb-bf92-49fc-b603-f32a2c633069-00-2ilewbikzvnu8.janeway.replit.dev/notes/$noteId', //essa interpolacao e importante pois, sem ela, perde-se todos os dados. ela garante q o update ocorre apenas no noteId desejado
    //     data: note.toMap());

    // note.noteId = noteId;
    // database[noteId] = note;
    // _controller.sink.add(noteId);
    return noteId;
  }

  Future<String> deleteNote(String noteId) async {
    noteCollection.doc(uid).collection("my_notes").doc(noteId).delete();
    
    // _dio.delete(
    //     'https://c9fbeafb-bf92-49fc-b603-f32a2c633069-00-2ilewbikzvnu8.janeway.replit.dev/notes/$noteId');

    // database.remove(noteId);
    // _controller.sink.add(noteId);
    return noteId;
  }

  Future<List<Note>> getNoteList() async {
    // Response response = await _dio.get(
    //     'https://c9fbeafb-bf92-49fc-b603-f32a2c633069-00-2ilewbikzvnu8.janeway.replit.dev/notes');
    QuerySnapshot querySnapshot = await noteCollection.doc(uid).collection("my_notes").get();
    
    
    List<Note> noteList = [];

    for (var doc in querySnapshot.docs){
      
      Note note = Note.fromMap(doc.data());
      note.noteId = doc.id;
      noteList.add(note);
    }


    // _controller.sink.add(noteList); // antes nao possuiamos stream, por isso esse sink era colocado aqui. Para aula 10, isso esta em outro lugar, pois quem deve informar se algo ocorreu ou nao eh o backend
    return noteList;
  }

  /*
    Parte da Stream
  */

  StreamController? _controller;

  Stream get stream {
    if (_controller == null) {
      _controller = StreamController();

      Socket socket = io(
          "https://c9fbeafb-bf92-49fc-b603-f32a2c633069-00-2ilewbikzvnu8.janeway.replit.dev/",
          OptionBuilder().setTransports(["websocket"]).build());

      socket.on("server_information", (data) {
        _controller!.sink.add(data);
      });
    }
    return _controller!.stream;
  }
}
