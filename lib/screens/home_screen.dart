import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../widgets/offer_card.dart';
import '../widgets/video_lesson_card.dart';
import 'create_video_lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  final DemoStore store;

  const HomeScreen({super.key, required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all';
  String _mode = 'swap';
  String _query = '';

  static const _swapFilters = {
    'all': 'Все',
    'offer': 'Могу',
    'request': 'Хочу',
  };
  static const _videoFilters = {
    'all': 'Все',
    'math': 'Математика',
    'it': 'IT',
    'design': 'Дизайн',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'SkillSwap',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE9E6FF),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'swap', label: Text('Обмен')),
                  ButtonSegment(value: 'videos', label: Text('Видеоуроки')),
                ],
                selected: {_mode},
                onSelectionChanged: (value) => setState(() {
                  _mode = value.first;
                  _filter = 'all';
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: const InputDecoration(
                  hintText: 'Найти навык или человека',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final filter
                      in (_mode == 'videos' ? _videoFilters : _swapFilters)
                          .entries)
                    ChoiceChip(
                      label: Text(filter.value),
                      selected: _filter == filter.key,
                      onSelected: (_) => setState(() => _filter = filter.key),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.store,
                builder: (context, _) =>
                    _mode == 'videos' ? _videoList() : _offerList(),
              ),
            ),
          ],
        ),
      );

  Widget _offerList() {
    final query = _query.toLowerCase();
    final offers = widget.store.offers.where((offer) {
      final matchesType = _filter == 'all' || offer.type == _filter;
      final matchesQuery = query.isEmpty ||
          '${offer.skill} ${offer.authorName} ${offer.description}'
              .toLowerCase()
              .contains(query);
      return matchesType && matchesQuery;
    }).toList();
    if (offers.isEmpty) {
      return const Center(child: Text('Пока нет карточек. Нажми +'));
    }
    return ListView(
      children: [
        for (final offer in offers)
          OfferCard(
            id: offer.id,
            data: offer.toMap(),
            store: widget.store,
            showDelete: offer.authorId == DemoStore.currentUserId,
          ),
      ],
    );
  }

  Widget _videoList() {
    final query = _query.toLowerCase();
    final lessons = widget.store.videoLessons.where((lesson) {
      final category = lesson.category.toLowerCase();
      final matchesCategory = _filter == 'all' ||
          (_filter == 'math' && category.contains('мат')) ||
          (_filter == 'it' && category.contains('it')) ||
          (_filter == 'design' && category.contains('диз'));
      final matchesQuery = query.isEmpty ||
          '${lesson.title} ${lesson.authorName} ${lesson.category}'
              .toLowerCase()
              .contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateVideoLessonScreen(store: widget.store),
              ),
            ),
            icon: const Icon(Icons.video_call_outlined),
            label: const Text('Добавить видеоурок'),
          ),
        ),
        if (lessons.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Уроков по этому фильтру пока нет')),
          ),
        for (final lesson in lessons) VideoLessonCard(lesson: lesson),
      ],
    );
  }
}
