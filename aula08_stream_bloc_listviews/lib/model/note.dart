class Note {
  String title = '';
  String description = '';
  String noteId = '';

  Note() {
    title = '';
    description = '';
    noteId = '';
  }

  Note.withData({this.title = '', this.description = ''});

  //construtor util para tratar recebimento de arquivos json, que o flutter converte para map
  Note.fromMap(map) {
    title = map['title'];
    description = map['description'];
  }

  toMap() {
    var map = <String, dynamic>{};
    map['title'] = title;
    map['description'] = description;

    return map;
  }
}
