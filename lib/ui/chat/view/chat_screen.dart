import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/chat/viewmodel/chat_vm.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ListView(children: chats.map(Text.new).toList()),
    );
  }
}
