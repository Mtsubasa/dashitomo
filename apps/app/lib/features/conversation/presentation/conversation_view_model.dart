import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConversationAuthor { character, user }

class ConversationMessage {
  const ConversationMessage({required this.author, required this.text});

  final ConversationAuthor author;
  final String text;
}

class ConversationState {
  const ConversationState({required this.messages});

  final List<ConversationMessage> messages;
}

class ConversationViewModel extends Notifier<ConversationState> {
  @override
  ConversationState build() {
    return const ConversationState(
      messages: [
        ConversationMessage(
          author: ConversationAuthor.character,
          text: '今日は何を食べたと？',
        ),
      ],
    );
  }

  bool send(String message) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      return false;
    }

    state = ConversationState(
      messages: [
        ...state.messages,
        ConversationMessage(
          author: ConversationAuthor.user,
          text: normalizedMessage,
        ),
        ConversationMessage(
          author: ConversationAuthor.character,
          text: '「$normalizedMessage」って聞けて、うれしか〜！',
        ),
      ],
    );
    return true;
  }
}

final conversationViewModelProvider =
    NotifierProvider<ConversationViewModel, ConversationState>(
      ConversationViewModel.new,
    );
