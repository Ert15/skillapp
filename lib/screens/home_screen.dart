import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_mode.dart';
import '../widgets/offer_card.dart';

const _previewOffers = [
  {
    'authorId': 'preview-maria',
    'authorName': 'Мария',
    'type': 'offer',
    'skill': 'Английский язык',
    'wantInReturn': 'Помощь с математикой',
    'description': 'Помогу разговориться и разобраться с грамматикой.',
  },
  {
    'authorId': 'preview-ivan',
    'authorName': 'Иван',
    'type': 'request',
    'skill': 'Хочу научиться играть на гитаре',
    'wantInReturn': 'Могу помочь с программированием',
    'description': 'Ищу занятия для начинающего.',
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all'; // all | offer | request
  String _mode = 'swap';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('SkillSwap',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE9E6FF),
              ),
            ),
          ],
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'swap', label: Text('Обмен')),
                ButtonSegment(value: 'videos', label: Text('Видеоуроки')),
              ],
              selected: {_mode},
              onSelectionChanged: (value) =>
                  setState(() => _mode = value.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Найти навык или человека',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Wrap(spacing: 8, children: [
              for (final f in (_mode == 'videos'
                      ? const {
                          'all': 'Все',
                          'math': 'Математика',
                          'it': 'IT',
                          'design': 'Дизайн'
                        }
                      : const {
                          'all': 'Все',
                          'offer': 'Могу',
                          'request': 'Хочу'
                        })
                  .entries)
                ChoiceChip(
                  label: Text(f.value),
                  selected: _filter == f.key,
                  onSelected: (_) => setState(() => _filter = f.key),
                ),
            ]),
          ),
          Expanded(
            child: _mode == 'videos'
                ? ListView(
                    children: const [
                      _VideoCard(
                          title: 'Производная за 10 минут',
                          author: 'Ерсултан А.',
                          category: 'Математика',
                          color: Color(0xFFDCD9FF)),
                      _VideoCard(
                          title: 'Основы дизайна',
                          author: 'Мария К.',
                          category: 'Дизайн',
                          color: Color(0xFFFFE6DD)),
                    ],
                  )
                : previewMode
                    ? ListView(
                        children: [
                          for (var i = 0; i < _previewOffers.length; i++)
                            if (_filter == 'all' ||
                                _previewOffers[i]['type'] == _filter)
                              OfferCard(
                                id: 'preview-$i',
                                data: _previewOffers[i],
                              ),
                        ],
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('offers')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (c, s) {
                          if (!s.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final docs = s.data!.docs
                              .where((d) =>
                                  _filter == 'all' ||
                                  (d.data() as Map)['type'] == _filter)
                              .toList();
                          if (docs.isEmpty) {
                            return const Center(
                                child: Text('Пока нет баннеров. Нажми +'));
                          }
                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (c, i) => OfferCard(
                              id: docs[i].id,
                              data: docs[i].data() as Map<String, dynamic>,
                            ),
                          );
                        },
                      ),
          ),
        ]),
      );
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String author;
  final String category;
  final Color color;

  const _VideoCard({
    required this.title,
    required this.author,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 110,
            color: color,
            child: const Center(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.play_arrow, color: Color(0xFF5B55D6)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(author,
                          style: TextStyle(color: Colors.grey.shade600)),
                    ]),
              ),
              Chip(label: Text(category)),
            ]),
          ),
        ]),
      );
}
