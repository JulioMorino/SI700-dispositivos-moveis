import 'dart:typed_data';

class Note {
  String title = "";
  String description = "";
  String noteId = "";
  String? fileBytes = "";

  Note() {
    title = "";
    description = "";
    noteId = "";
    fileBytes = "";
  }

  Note.withData(
      {this.title = "",
      this.description = "",
      this.noteId = "",
      this.fileBytes = ""});

  Note.fromMap(map) {
    title = map["title"];
    description = map["description"];
    fileBytes = map["fileBytes"];
  }

  toMap() {
    var map = <String, dynamic>{};
    map["title"] = title;
    map["description"] = description;
    map["fileBytes"] = fileBytes;
    //map["fileBytes"] = null;
    return map;
  }
}
