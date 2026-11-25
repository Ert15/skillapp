import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../screens/chat_screen.dart';

class OfferCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final DemoStore store;
  final bool showDelete;

  const OfferCard({
    super.key,
    required this.id,
    required this.data,
    required this.store,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOffer = data['type'] == 'offer';
    final authorId = data['authorId']?.toString() ?? 'demo-author-$id';
    final authorName = data['authorName']?.toString() ?? 'Студент';
    final mine = authorId == DemoStore.currentUserId;
    final color = isOffer ? const Color(0xFF5B55D6) : const Color(0xFFE98B63);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 60, color: color.withValues(alpha: 0.18)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(
                        isOffer ? 'МОГУ' : 'ХОЧУ',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: color.withValues(alpha: 0.12),
                      side: BorderSide.none,
                    ),
                    const Spacer(),
                    if (showDelete && mine)
                      IconButton(
                        tooltip: 'Удалить карточку',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => store.removeOffer(id),
                      ),
                    if (!mine)
                      IconButton(
                        tooltip: store.isFavorite(id)
                            ? 'Убрать из избранного'
                            : 'В избранное',
                        icon: Icon(
                          store.isFavorite(id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: store.isFavorite(id) ? Colors.red : null,
                        ),
                        onPressed: () => store.toggleFavorite(id),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  authorName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _SkillBox(
                  label: isOffer ? 'УМЕЮ' : 'ХОЧУ',
                  value: data['skill']?.toString() ?? '',
                  color: isOffer
                      ? const Color(0xFFEDEBFF)
                      : const Color(0xFFFFEEE8),
                  labelColor: color,
                ),
                const SizedBox(height: 7),
                _SkillBox(
                  label: isOffer ? 'ИЩУ' : 'МОГУ',
                  value: data['wantInReturn']?.toString() ?? '',
                  color: isOffer
                      ? const Color(0xFFFFEEE8)
                      : const Color(0xFFEDEBFF),
                  labelColor: color,
                ),
                if ((data['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    data['description'].toString(),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: mine
                        ? null
                        : () {
                            final chat = store.openChat(authorId, authorName);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  store: store,
                                  chatId: chat.id,
                                ),
                              ),
                            );
                          },
                    child: const Text('ОТПРАВИТЬ ЗАПРОС'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color labelColor;

  const _SkillBox({
    required this.label,
    required this.value,
    required this.color,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 9, color: labelColor)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
