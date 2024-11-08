import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topico_navegacao_de_telas/data/generic_data_provider.dart';
import '../model/answer.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  late Answer answers;
  String answerId = "";
  int numQuestions;

  ManageBloc({required this.numQuestions})
      : super(ManageState.build(numQuestions)) {
    answers = Answer(numQuestions: numQuestions);
    on<CreateRecord>((event, emit) async {
      final newAnswer = Answer(numQuestions: numQuestions);
      answerId = await GenericDataProvider.helper.insertAnswer(newAnswer);
      print("Acabou de salvar o id: ${answerId}");
      emit(ManageState(
          answers: newAnswer,
          answerId:
              answerId)); //comentar no video, antes usava apenas ManageState
    });

    on<UpdateRecord>((event, emit) async {
      answerId = event.answerId;
      print("passou answerId: $answerId para o answerToUpdate");
      final answerToUpdate =
          await GenericDataProvider.helper.getAnswer(answerId);

      answers = answerToUpdate;
      emit(ManageState(answers: answers, answerId: answerId));
    });

    on<DeleteRecord>((event, emit) {
      GenericDataProvider.helper.deleteAnswer(event.answerId);
      answerId = "";
      emit(ManageState(
          answers: Answer(numQuestions: numQuestions), answerId: answerId));
    });

    on<SwapAnswer>((event, emit) {
      final updatedAnswer = state.answers
        ..swapAnswer(event.question, event.value);
      GenericDataProvider.helper.updateAnswer(answerId, updatedAnswer);
      emit(ManageState(answers: updatedAnswer, answerId: answerId));
    });

    on<SetAnswer>((event, emit) {
      final updatedAnswer = state.answers
        ..setAnswer(event.question, event.value);
      GenericDataProvider.helper.updateAnswer(answerId, updatedAnswer);
      emit(ManageState(answers: updatedAnswer, answerId: answerId));
    });

    on<WriteAnswer>((event, emit) {
      final updatedAnswer = state.answers
        ..writeAnswer(event.question, event.value);
      GenericDataProvider.helper.updateAnswer(answerId, updatedAnswer);
      emit(ManageState(answers: updatedAnswer, answerId: answerId));
    });
  }

  //CRUD RESPOSTAS
  createRecord({required Answer answer}) {
    GenericDataProvider.helper.insertAnswer(answer);
  }

  updateRecord({required String answerId}) async {
    Answer answerToUpdate =
        await GenericDataProvider.helper.getAnswer(answerId);
    GenericDataProvider.helper.updateAnswer(answerId, answerToUpdate);
  }

  deleteRecord({required String answerId}) {
    GenericDataProvider.helper.deleteAnswer(answerId);
  }

  //MANIPULACAO RESPOSTAS
  swapAnswer(
      {required Answer answer, required int question, required int value}) {
    answer.swapAnswer(question, value);
  }

  setAnswer(
      {required Answer answer, required int question, required int value}) {
    answer.setAnswer(question, value);
  }

  writeAnswer(
      {required Answer answer, required int question, required String value}) {
    answer.writeAnswer(question, value);
  }
}

abstract class ManageEvent {}

class SwapAnswer extends ManageEvent {
  int question;
  int value;
  SwapAnswer({required this.question, required this.value});
}

class SetAnswer extends ManageEvent {
  int question;
  int value;
  SetAnswer({required this.question, required this.value});
}

class WriteAnswer extends ManageEvent {
  int question;
  String value;
  WriteAnswer({required this.question, required this.value});
}

class CreateRecord extends ManageEvent {}

class UpdateRecord extends ManageEvent {
  String answerId;
  UpdateRecord({required this.answerId});
}

class DeleteRecord extends ManageEvent {
  String answerId;
  DeleteRecord({required this.answerId});
}

class ManageState {
  late Answer answers;
  late String answerId;

  ManageState({required this.answers, required this.answerId});

  ManageState.build(int numQuestions) {
    answers = Answer(numQuestions: numQuestions);
    answerId = "";
  }
}
