import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/chat_provider.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  String lChat = '';
  ChatBloc() : super(ChatState()) {
    ChatProvider.helper.stream.listen((resposta) {
      add(ServerEvent(resposta));
    });

    on<ChatEvent>(
      (event, emit) {
        if (event is UserEvent) {
          emit(ChatState(
            chatValue: "$lChat\n <h3 align = right>${event.message}</h3>",
          ));
        }

        if (event is ServerEvent) {
          emit(ChatState(
            chatValue: "$lChat\n <h3 align = left>${event.message}</h3>",
          ));
        }
      },
    );
  }
}

abstract class ChatEvent {
  String message;

  ChatEvent(this.message);
}

class UserEvent extends ChatEvent {
  UserEvent(super.message);
}

class ServerEvent extends ChatEvent {
  ServerEvent(super.message);
}

class ChatState {
  String chatValue;

  ChatState({this.chatValue = ''});
}
