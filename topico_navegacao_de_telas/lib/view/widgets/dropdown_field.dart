import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/answer_manager.dart';
import '../../model/question.dart';

class QuestionDropDownField extends StatelessWidget {
  final Question question;
  final int questionIndex;

  const QuestionDropDownField({
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
        _buildDropdown(),
      ],
    );
  }

  Widget _buildDropdown() {
    return BlocBuilder<ManageBloc, ManageState>(
      builder: (context, state) {
        int? selectedValue = state.answers.getAnswer(questionIndex).isNotEmpty
            ? state.answers.getAnswer(questionIndex)[0]
            : null;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<int>(
            value: selectedValue,
            decoration: InputDecoration(
              labelText: question.subTitulo,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            items: List.generate(
              question.alternatives.length,
              (index) => DropdownMenuItem<int>(
                value: index,
                child: Text(question.alternatives[index]),
              ),
            ),
            //mantendo o value como int como ulisses mencionou em sala
            onChanged: (int? value) {
              if (value != null) {
                BlocProvider.of<ManageBloc>(context)
                    .add(SetAnswer(question: questionIndex, value: value));
              }
            },
          ),
        );
      },
    );
  }
}
