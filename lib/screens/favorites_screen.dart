import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_mode.dart';
import '../widgets/offer_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    if (previewMode) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Избранное',
                style: TextStyle(fontWeight: FontWeight.bold))),
        body: ListView(
          children: const [
            OfferCard(
              id: 'preview-favorite',
              data: {
                'authorId': 'preview-maria',
                'authorName': 'Мария',
                'type': 'offer',
                'skill': 'Английский язык',
                'wantInReturn': 'Помощь с математикой',
                'description':
                    'Помогу разговориться и разобраться с грамматикой.',
              },
            ),
          ],
        ),
      );
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .snapshots(),
        builder: (c, s) {
          if (s.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Не удалось загрузить избранное: ${s.error}'),
              ),
            );
          }
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text('Ничего нет. Нажми ♥ на баннере'));
          return ListView(
            children: [
              for (final d in docs)
                OfferCard(id: d.id, data: d.data() as Map<String, dynamic>)
            ],
          );
        },
      ),
    );
  }
}
