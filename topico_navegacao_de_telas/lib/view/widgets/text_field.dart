import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/answer_manager.dart';
import '../../model/question.dart';

class QuestionTextField extends StatelessWidget {
  final Question question;
  final int questionIndex;

  const QuestionTextField({
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
        if (question.titulo.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Text(
              question.titulo,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        _buildTextField(),
      ],
    );
  }

  Widget _buildTextField() {
    return BlocBuilder<ManageBloc, ManageState>(
      builder: (context, state) {
        String? currentAnswer =
            state.answers.getAnswer(questionIndex).isNotEmpty
                ? state.answers.getAnswer(questionIndex)[0]
                : '';

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            initialValue: currentAnswer,
            decoration: InputDecoration(
              labelText: question.subTitulo,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) {
              BlocProvider.of<ManageBloc>(context)
                  .add(WriteAnswer(question: questionIndex, value: value));
            },
          ),
        );
      },
    );
  }
}
