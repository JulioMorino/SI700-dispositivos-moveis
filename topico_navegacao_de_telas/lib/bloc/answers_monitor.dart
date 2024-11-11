import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topico_navegacao_de_telas/data/generic_data_provider.dart';
import 'package:topico_navegacao_de_telas/model/answer_collection.dart';

class MonitorBloc extends Bloc<MonitorEvent, MonitorState> {
  late AnswerCollection answerCollection;

  MonitorBloc()
      : super(MonitorState(
            answerCollection: AnswerCollection(idList: [], answerList: []))) {
    answerCollection = AnswerCollection(idList: [], answerList: []);
    GenericDataProvider.helper.stream.listen((event) {
      final String answerId = event[0];
      final answer = event[1];
      if (answer == null) {
        //DELETE CHAMADO
        answerCollection.deleteAnswerOfId(answerId);
      } else {
        //INSERT OU UPDATE
        answerCollection.updateOrInsertAnswerOfId(answerId, answer);
      }

      // Emite o evento UpdateList para atualizar a interface
      add(UpdateList());
    });

    on<AskNewList>(
      (event, emit) {
        Future<AnswerCollection> allAnswers =
            GenericDataProvider.helper.getAllAnswers();
        answerCollection = allAnswers as AnswerCollection;
        emit(MonitorState(answerCollection: answerCollection));
      },
    );
    on<UpdateList>(
      (event, emit) {
        emit(MonitorState(answerCollection: answerCollection));
      },
    );

    add(AskNewList());
  }
}

class MonitorState {
  AnswerCollection answerCollection;
  MonitorState({required this.answerCollection});
}

abstract class MonitorEvent {}

class AskNewList extends MonitorEvent {}

class UpdateList extends MonitorEvent {}
