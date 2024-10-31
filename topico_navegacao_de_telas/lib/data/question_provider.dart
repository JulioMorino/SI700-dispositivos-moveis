import '../model/question.dart';
import '../model/questions.dart';

class QuestionProvider {
  static QuestionProvider helper = QuestionProvider._createInstance();
  QuestionProvider._createInstance();
  Questions questions = Questions(questionList: [
    Question(
        titulo: "Pergunta 1",
        subTitulo: "Qual o sentido da vida",
        alternatives: ["a) dormir", "b) comer", "c) beber", "d) não sei"],
        type: QuestionType.multiple),
    Question(
        titulo: "Pergunta 2",
        subTitulo: "Camarão que dorme a onda:",
        alternatives: [
          "a)lava",
          "b)leva",
          "c)afoga",
          "d)todas alternativas anteriores"
        ],
        type: QuestionType.singleShort),
    Question(
        titulo: "Pergunta 3",
        subTitulo: "aaaaaaa",
        alternatives: [
          "a)bbbbb",
          "b)ccccc",
          "c)dddd",
          "d)todas alternativas anteriores"
        ],
        type: QuestionType.text),
// Adicione mais perguntas conforme necessário
  ], breakpoints: [
    1, 2, 4, 5 // Defina os pontos de quebra desejados
  ]);
}
