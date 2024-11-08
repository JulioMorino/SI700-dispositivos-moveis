import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/answer_manager.dart';
import '../../model/question.dart';

class QuestionCheckBoxField extends StatelessWidget {
  final Question question;
  final int questionIndex;
  const QuestionCheckBoxField({
    super.key,
    required this.question,
    required this.questionIndex,
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
              )),
        _buildCheckboxes()
      ],
    );
  }

  Widget _buildCheckboxes() {
    List<Widget> checkboxes = [];
    for (int i = 0; i < question.alternatives.length; i++) {
      checkboxes.add(Row(children: [
        BlocBuilder<ManageBloc, ManageState>(
          builder: (context, state) {
            List answer = state.answers.getAnswer(questionIndex);
            return Checkbox(
              value: answer.contains(i),
              onChanged: (bool? value) {
                if (value != null) {
                  BlocProvider.of<ManageBloc>(context)
                      .add(SwapAnswer(question: questionIndex, value: i));
                }
              },
            );
          },
        ),
        Text(question.alternatives[i])
      ]));
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
        child: Column(children: checkboxes),
      ),
    );
  }
}
