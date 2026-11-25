import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../widgets/offer_card.dart';
import '../widgets/video_lesson_card.dart';
import 'create_offer_screen.dart';
import 'create_video_lesson_screen.dart';

class ProfileScreen extends StatefulWidget {
  final DemoStore store;
  final String profileName;
  final VoidCallback onSignOut;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onOpenChats;

  const ProfileScreen({
    super.key,
    required this.store,
    required this.profileName,
    required this.onSignOut,
    required this.onNameChanged,
    required this.onOpenChats,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _profileTab = 0;
  bool _editing = false;

  Future<void> _editName() async {
    final controller = TextEditingController(text: widget.profileName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Имя профиля'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Имя'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !mounted) return;
    widget.onNameChanged(name.trim());
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profileName;
    final initial = name.isEmpty ? 'S' : name[0].toUpperCase();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _editName,
            child: const Text('Изменить'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFE9E6FF),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Студент, люблю сети и серверы',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: const [
                Chip(label: Text('Telegram')),
                Chip(label: Text('WhatsApp')),
                Chip(label: Text('Instagram')),
              ],
            ),
            Text(
              'Контакты видны только тем, с кем вы согласовали обмен',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
            const SizedBox(height: 14),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Мои карточки')),
                ButtonSegment(value: 1, label: Text('Мои уроки')),
              ],
              selected: {_profileTab},
              onSelectionChanged: (value) =>
                  setState(() => _profileTab = value.first),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Опубликовано'),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _editing = !_editing),
                  child: Text(_editing ? 'Готово' : 'Править'),
                ),
              ],
            ),
            if (_profileTab == 0) ...[
              if (widget.store.myOffers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('У тебя пока нет карточек'),
                ),
              for (final offer in widget.store.myOffers)
                OfferCard(
                  id: offer.id,
                  data: offer.toMap(),
                  store: widget.store,
                  showDelete: _editing,
                ),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateOfferScreen(
                      store: widget.store,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Добавить карточку'),
              ),
            ] else ...[
              if (widget.store.myVideoLessons.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('У тебя пока нет видеоуроков'),
                ),
              for (final lesson in widget.store.myVideoLessons)
                VideoLessonCard(
                  lesson: lesson,
                  onDelete: _editing
                      ? () => widget.store.removeVideoLesson(lesson.id)
                      : null,
                ),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CreateVideoLessonScreen(store: widget.store),
                  ),
                ),
                icon: const Icon(Icons.video_call_outlined),
                label: const Text('Добавить видеоурок'),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: widget.onOpenChats,
                  child: const Text('Запросы'),
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Настройки скоро появятся')),
                  ),
                  child: const Text('Настройки'),
                ),
                TextButton(
                  onPressed: widget.onSignOut,
                  child: const Text('Выйти'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Демо-данные хранятся только пока приложение открыто.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
