import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../bloc/chat_bloc.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  reverse: true,
                  child: HtmlWidget(
                    state.chatValue,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite sua mensagem...',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                final message = _textEditingController.text.trim();
                if (message.isNotEmpty) {
                  BlocProvider.of<ChatBloc>(context).add(UserEvent(message));
                  _textEditingController.clear();
                }
              },
              child: const Text('Enviar'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: HtmlWidget('<h2>Mensagens</h2>'),
          ),
        ],
      ),
    );
  }
}
