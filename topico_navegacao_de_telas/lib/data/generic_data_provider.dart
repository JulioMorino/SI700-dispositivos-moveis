import 'dart:async';

import '../model/answer.dart';
import '../model/answer_collection.dart';

class GenericDataProvider {
  int numInsertions = 0;
  Map<String, List> _database = {};
  StreamController _controller = StreamController();
  static GenericDataProvider helper = GenericDataProvider._createInstance();

  GenericDataProvider._createInstance();

  Future<String> insertAnswer(Answer answer) async {
    String answerId = 'answer$numInsertions';
    _database[answerId] = answer.answerList;
    numInsertions++;
    _controller.add([answerId, answer]);
    return answerId;
  }

  Future<String> updateAnswer(String answerId, Answer answer) async {
    _database[answerId] = answer.answerList;
    _controller.add([answerId, answer]);
    return answerId;
  }

  Future<String> deleteAnswer(String answerId) async {
    _database.remove(answerId);
    _controller.add([answerId, null]);
    return answerId;
  }

  Future<Answer> getAnswer(String answerId) async {
    // Recupera o answerList do banco de dados para o answerId
    List? answerList = _database[answerId];
    if (answerList == null) {
      throw Exception("Answer ID não encontrado.");
    }
    // Retorna a Answer com a lista de respostas correta
    return Answer.withData(answerList: answerList);
  }

  Future<AnswerCollection> getAllAnswers() async {
    AnswerCollection collection = AnswerCollection(idList: [], answerList: []);
    _database.forEach((key, value) {
      collection.idList.add(key);
      collection.answerList.add(Answer(numQuestions: value.length));
    });
    return collection;
  }

  notify(String answerId, Answer? answer) async {
    _controller.add([answerId, answer]);
  }

  Stream get stream => _controller.stream;
}
