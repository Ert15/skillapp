import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_mode.dart';
import '../screens/chat_screen.dart';

class OfferCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final bool showDelete;
  const OfferCard(
      {super.key,
      required this.id,
      required this.data,
      this.showDelete = false});

  @override
  Widget build(BuildContext context) {
    final me = previewMode ? null : FirebaseAuth.instance.currentUser;
    final isOffer = data['type'] == 'offer';
    final mine = me != null && data['authorId'] == me.uid;
    final color = isOffer ? const Color(0xFF5B55D6) : const Color(0xFFE98B63);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 60, color: color.withValues(alpha: 0.18)),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Chip(
                label: Text(isOffer ? 'МОГУ' : 'ХОЧУ',
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
                backgroundColor: color.withValues(alpha: 0.12),
                side: BorderSide.none,
              ),
              const Spacer(),
              if (me != null && showDelete && mine)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => FirebaseFirestore.instance
                      .collection('offers')
                      .doc(id)
                      .delete(),
                ),
              if (me != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(me.uid)
                      .collection('favorites')
                      .doc(id)
                      .snapshots(),
                  builder: (c, s) {
                    if (s.hasError) {
                      return IconButton(
                        icon: const Icon(Icons.error_outline),
                        tooltip: 'Не удалось загрузить избранное',
                        onPressed: () => ScaffoldMessenger.of(c).showSnackBar(
                          SnackBar(
                              content: Text('Ошибка избранного: ${s.error}')),
                        ),
                      );
                    }
                    final fav = s.data?.exists ?? false;
                    return IconButton(
                      icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                          color: fav ? Colors.red : null),
                      onPressed: () async {
                        final favorite = FirebaseFirestore.instance
                            .collection('users')
                            .doc(me.uid)
                            .collection('favorites')
                            .doc(id);
                        try {
                          if (fav) {
                            await favorite.delete();
                          } else {
                            await favorite.set(data);
                          }
                          if (c.mounted) {
                            ScaffoldMessenger.of(c).showSnackBar(
                              SnackBar(
                                content: Text(
                                  fav
                                      ? 'Удалено из избранного'
                                      : 'Добавлено в избранное',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        } on FirebaseException catch (e) {
                          if (c.mounted) {
                            ScaffoldMessenger.of(c).showSnackBar(
                              SnackBar(
                                content: Text(e.message ??
                                    'Не удалось изменить избранное'),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
            ]),
            const SizedBox(height: 4),
            Text(data['authorName'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isOffer ? const Color(0xFFEDEBFF) : const Color(0xFFFFEEE8),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isOffer ? 'УМЕЮ' : 'ХОЧУ',
                        style: TextStyle(fontSize: 9, color: color)),
                    Text(data['skill'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isOffer ? const Color(0xFFFFEEE8) : const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isOffer ? 'ИЩУ' : 'МОГУ',
                        style: TextStyle(fontSize: 9, color: color)),
                    Text(data['wantInReturn'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
            ),
            if ((data['description'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(data['description'],
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: me != null && !mine
                    ? () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('requests')
                              .add({
                            'offerId': id,
                            'fromUid': me.uid,
                            'fromName': me.displayName ?? 'Студент',
                            'toUid': data['authorId'],
                            'toName': data['authorName'] ?? 'Студент',
                            'status': 'pending',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  otherUid: data['authorId'],
                                  otherName: data['authorName'] ?? 'Студент',
                                ),
                              ),
                            );
                          }
                        } on FirebaseException catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.message ??
                                      'Не удалось отправить запрос',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: const Text('ОТПРАВИТЬ ЗАПРОС'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
