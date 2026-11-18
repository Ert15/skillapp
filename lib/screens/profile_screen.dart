import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_mode.dart';
import '../widgets/offer_card.dart';
import 'create_offer_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _savingName = false;
  int _profileTab = 0;

  Future<void> _editName(User user) async {
    final controller = TextEditingController(text: user.displayName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Имя профиля'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Имя',
            border: OutlineInputBorder(),
          ),
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

    setState(() => _savingName = true);
    try {
      await user.updateDisplayName(name);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'name': name, 'email': user.email},
        SetOptions(merge: true),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Имя сохранено')),
        );
        setState(() {});
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Не удалось сохранить имя')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = previewMode ? null : FirebaseAuth.instance.currentUser;
    final name = u?.displayName ?? 'Сатыбалды Д.';
    final initial = name.isEmpty ? 'S' : name[0].toUpperCase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed:
                u == null ? null : (_savingName ? null : () => _editName(u)),
            child: const Text('Изменить'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE9E6FF),
              child: Text(initial,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Студент, люблю сети и серверы',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 6, children: const [
            Chip(label: Text('Telegram')),
            Chip(label: Text('WhatsApp')),
            Chip(label: Text('Instagram')),
          ]),
          Text('Контакты видны только тем, с кем вы согласовали обмен',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
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
          Row(children: [
            const Text('Опубликовано'),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Править')),
          ]),
          if (_profileTab == 0)
            u == null
                ? OfferCard(
                    id: 'preview-profile',
                    data: const {
                      'authorId': 'preview-profile',
                      'authorName': 'Сатыбалды Д.',
                      'type': 'offer',
                      'skill': 'Настрою сервер',
                      'wantInReturn': 'Помощь с математикой',
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('offers')
                        .where('authorId', isEqualTo: u.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                            'Не удалось загрузить карточки: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('У тебя пока нет карточек'),
                        );
                      }
                      return Column(
                        children: [
                          for (final doc in snapshot.data!.docs)
                            OfferCard(
                              id: doc.id,
                              data: doc.data() as Map<String, dynamic>,
                              showDelete: true,
                            ),
                        ],
                      );
                    },
                  ),
          OutlinedButton(
            onPressed: () {
              if (u == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Карточка доступна после подключения Firebase')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOfferScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Добавить карточку'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: () {}, child: const Text('Запросы')),
              TextButton(onPressed: () {}, child: const Text('Настройки')),
              TextButton(
                  onPressed:
                      u == null ? null : () => FirebaseAuth.instance.signOut(),
                  child: const Text('Выйти')),
            ],
          ),
        ],
      ),
    );
  }
}
