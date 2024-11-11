import '../model/question.dart';
import '../model/questions.dart';

class QuestionProvider {
  static QuestionProvider helper = QuestionProvider._createInstance();
  QuestionProvider._createInstance();
  Questions questions = Questions(questionList: [
    Question(
        titulo: "Dado pessoal",
        subTitulo: "Indique seu nome completo",
        alternatives: [],
        type: QuestionType.text),
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
        subTitulo: "Gostou das questões?(0 a 5)",
        alternatives: [
          "0 - muito ruim, não recomendarei para outras pessoas.",
          "1 - faltou muitas perguntas importantes.",
          "2 - mais ou menos.",
          "3 - neutro.",
          "4 - questões boas, reflexivas e importantes.",
          "5 - absolute cinema."
        ],
        type: QuestionType.singleLong),
    Question(
        titulo: "Feedback",
        subTitulo:
            "Escreva aqui seu feedback para melhorarmos questões futuras",
        alternatives: [],
        type: QuestionType.text),
// Adicione mais perguntas conforme necessário
  ], breakpoints: [
    1, 2, 4, 5 // Defina os pontos de quebra desejados
  ]);
}
