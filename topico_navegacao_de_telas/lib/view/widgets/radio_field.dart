import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/answer_manager.dart';
import '../../model/question.dart';

class QuestionRadioButtonField extends StatelessWidget {
  final Question question;
  final int questionIndex;

  const QuestionRadioButtonField({
    super.key,
    required this.question, //conteudo da questao: titulo e alternativas
    required this.questionIndex, //importante para o bloc saber qual a questao
  });

  @override
  Widget build(BuildContext context) {
    return _buildQuestion();
  }

  Widget _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.titulo != "")
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Text(
              question.titulo,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        _buildRadioButtons(),
      ],
    );
  }

  Widget _buildRadioButtons() {
    List<Widget> radioButtons = [];
    for (int i = 0; i < question.alternatives.length; i++) {
      //criando radio buttons para cada alternativa
      radioButtons.add(
        BlocBuilder<ManageBloc, ManageState>(
          builder: (context, state) {
            int? selectedValue =
                state.answers.getAnswer(questionIndex).isNotEmpty
                    ? state.answers.getAnswer(questionIndex)[0]
                    : null;
            return RadioListTile<int>(
              title: Text(question.alternatives[i]),
              value: i,
              groupValue: selectedValue,
              onChanged: (int? value) {
                if (value != null) {
                  BlocProvider.of<ManageBloc>(context)
                      .add(SetAnswer(question: questionIndex, value: value));
                }
              },
            );
          },
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: question.subTitulo,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Column(children: radioButtons),
      ),
    );
  }
}
