import 'package:flutter/material.dart';
import '../demo_store.dart';

class ChatScreen extends StatefulWidget {
  final DemoStore store;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.store,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    widget.store.sendMessage(widget.chatId, text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.store.chatById(widget.chatId);
    return Scaffold(
      appBar: AppBar(title: Text(chat?.otherName ?? 'Чат')),
      body: chat == null
          ? const Center(child: Text('Чат не найден'))
          : Column(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: widget.store,
                    builder: (context, _) {
                      final currentChat = widget.store.chatById(widget.chatId);
                      final messages = currentChat?.messages ?? const [];
                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('Начни переписку первым'),
                        );
                      }
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index];
                          return Align(
                            alignment: message.isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: message.isMine
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: message.isMine
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFFE2E0EE),
                                      ),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isMine
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Сообщение...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Отправить',
                          icon: const Icon(Icons.send),
                          onPressed: _send,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
