import '../model/answer.dart';

class AnswerCollection {
  List<String> idList = [];
  List<Answer> answerList = [];

  AnswerCollection({required this.idList, required this.answerList});

  int length() {
    return answerList.length;
  }

  Answer getAnswerAtIndex(int index) {
    return answerList[index];
  }

  String getIdAtIndex(int index) {
    return idList[index];
  }

  int getIndexOfId(String id) {
    return idList.indexOf(id);
  }

  void updateAnswerOfId(String id, Answer answer) {
    int index = getIndexOfId(id);
    if (index != -1) {
      answerList[index] = answer;
    }
  }

  void deleteAnswerOfId(String id) {
    int index = getIndexOfId(id);
    if (index != -1) {
      idList.removeAt(index);
      answerList.removeAt(index);
    }
  }

  void insertAnswerOfId(String id, Answer answer) {
    int index = getIndexOfId(id);
    if (index == -1) {
      idList.add(id);
      answerList.add(answer);
    }
  }

  @override
  String toString() {
    return 'AnswerList{idList: $idList, answerList: $answerList}';
  }

  void updateOrInsertAnswerOfId(String id, Answer answer) {
    int index = getIndexOfId(id);
    if (index != -1) {
      answerList[index] = answer;
    } else {
      idList.add(id);
      answerList.add(answer);
    }
  }
}
