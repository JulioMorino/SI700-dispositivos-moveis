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
    on<CreateRecord>((event, emit) {
      createRecord(answer: answers);
      emit(ManageState(answers: answers, answerId: answerId));
    });
    on<UpdateRecord>((event, emit) {
      updateRecord(answerId: event.answerId);
      emit(ManageState(answers: answers, answerId: answerId));
    });
    on<DeleteRecord>((event, emit) {
      deleteRecord(answerId: event.answerId);
      emit(ManageState(answers: answers, answerId: answerId));
    });
    on<SwapAnswer>((event, emit) {
      swapAnswer(answer: answers, question: event.question, value: event.value);
      emit(ManageState(answers: answers, answerId: answerId));
    });
    on<SetAnswer>((event, emit) {
      setAnswer(answer: answers, question: event.question, value: event.value);
      emit(ManageState(answers: answers, answerId: answerId));
    });
    on<WriteAnswer>((event, emit) {
      writeAnswer(
          answer: answers, question: event.question, value: event.value);
      emit(ManageState(answers: answers, answerId: answerId));
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
