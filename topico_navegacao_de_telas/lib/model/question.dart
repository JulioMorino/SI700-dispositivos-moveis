class Question {
  String titulo;
  String subTitulo;
  List<String> alternatives;
  QuestionType type;

  Question(
      {required this.titulo,
      required this.subTitulo,
      required this.alternatives,
      required this.type});
}

enum QuestionType { singleShort, singleLong, multiple, text }

//singleShort => crio widget RadioButton (somente uma resposta e poucas opcoes)
//singleLong  => 