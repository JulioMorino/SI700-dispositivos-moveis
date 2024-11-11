import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topico_navegacao_de_telas/bloc/answer_manager.dart';
import 'package:topico_navegacao_de_telas/bloc/answers_monitor.dart';
import 'package:topico_navegacao_de_telas/data/question_provider.dart';
import '../view/widgets/radio_field.dart';

import '../model/questions.dart';
import 'model/question.dart';
import '../view/widgets/dropdown_field.dart';
import 'view/screen/answers_list_view.dart';
import 'view/screen/questions_screen.dart';
import 'view/widgets/checkbox_field.dart';
import 'view/widgets/text_field.dart';

class AppRouter {
  int numQuestions = 0;
  int numScreens = 0;
  late ManageBloc _manageBloc;
  late MonitorBloc _monitorBloc;

  List<Widget> localBucket = [];
  AppRouter() {
    Questions questions = QuestionProvider.helper.questions;

    for (int i = 0; i < questions.questionList.length; i++) {
      Question e = questions.questionList[i];
      switch (e.type) {
        case QuestionType.singleShort:
          localBucket.add(QuestionRadioButtonField(
              question: questions.questionList[i], questionIndex: i));
        case QuestionType.singleLong:
          localBucket.add(QuestionDropDownField(
              question: questions.questionList[i], questionIndex: i));
        case QuestionType.multiple:
          localBucket.add(QuestionCheckBoxField(
              question: questions.questionList[i], questionIndex: i));
        case QuestionType.text:
          localBucket.add(QuestionTextField(
              question: questions.questionList[i], questionIndex: i));
        default:
          localBucket.add(Container());
      }
    }
    numQuestions = localBucket.length;
    numScreens = localBucket.length;
    _manageBloc = ManageBloc(numQuestions: numQuestions);
    _monitorBloc = MonitorBloc();
  }

  Route onGenerateRoute(RouteSettings route) {
    switch (route.name) {
      case "/":
        return MaterialPageRoute(builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _monitorBloc),
              BlocProvider.value(value: _manageBloc),
            ],
            child: const AnswerList(),
          );
        });
      case "/create":
        return MaterialPageRoute(builder: (_) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _manageBloc),
            ],
            child: QuestionsScreen(children: localBucket),
          );
        });

      default:
        return MaterialPageRoute(builder: (_) => const Text("Erro"));
    }
  }

  void dispose() {
    _manageBloc.close();
    _monitorBloc.close();
  }
}
