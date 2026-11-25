import 'package:flutter/material.dart';
import '../demo_store.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  final DemoStore store;

  const ChatsScreen({super.key, required this.store});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Чаты',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Запросы')),
                  ButtonSegment(value: 1, label: Text('Чаты')),
                ],
                selected: {_tab},
                onSelectionChanged: (value) =>
                    setState(() => _tab = value.first),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.store,
                builder: (context, _) =>
                    _tab == 0 ? _requestsList() : _chatsList(),
              ),
            ),
          ],
        ),
      );

  Widget _requestsList() {
    final requests = widget.store.requests;
    if (requests.isEmpty) {
      return const Center(child: Text('Новых запросов пока нет'));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final request in requests)
          _RequestTile(
            name: request.otherName,
            text: request.text,
            incoming: request.incoming,
            onDecline: () => widget.store.declineRequest(request.id),
            onAccept: () {
              final chat = widget.store.acceptRequest(request.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    store: widget.store,
                    chatId: chat.id,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _chatsList() {
    final chats = widget.store.chats;
    if (chats.isEmpty) {
      return const Center(child: Text('Чатов пока нет'));
    }
    return ListView(
      children: [
        for (final chat in chats)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE9E6FF),
              child: Text(
                chat.otherName.isEmpty ? '?' : chat.otherName[0].toUpperCase(),
              ),
            ),
            title: Text(chat.otherName),
            subtitle: Text(
              chat.lastMessage.isEmpty ? 'Начать переписку' : chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  store: widget.store,
                  chatId: chat.id,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String name;
  final String text;
  final bool incoming;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  const _RequestTile({
    required this.name,
    required this.text,
    required this.incoming,
    required this.onDecline,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE9E6FF),
                    child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          text,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (incoming) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        child: const Text('Отклонить'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        child: const Text('Принять'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
}
