import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_mode.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    if (previewMode) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Чаты',
                style: TextStyle(fontWeight: FontWeight.bold))),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Запросы')),
                ButtonSegment(value: 1, label: Text('Чаты')),
              ],
              selected: {_tab},
              onSelectionChanged: (value) => setState(() => _tab = value.first),
            ),
          ),
          Expanded(
            child: _tab == 0
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      _RequestTile(
                        name: 'Мария',
                        text: 'Хочет обменяться английским',
                        incoming: true,
                      ),
                      _RequestTile(
                        name: 'Иван',
                        text: 'Предлагает помощь с программированием',
                        incoming: false,
                      ),
                    ],
                  )
                : const Center(
                    child: Text('Активных чатов пока нет'),
                  ),
          ),
        ]),
      );
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Чаты',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Запросы')),
              ButtonSegment(value: 1, label: Text('Чаты')),
            ],
            selected: {_tab},
            onSelectionChanged: (value) => setState(() => _tab = value.first),
          ),
        ),
        Expanded(
          child: _tab == 0
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('requests')
                      .where('toUid', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Входящих запросов пока нет'));
                    }
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        for (final doc in snapshot.data!.docs)
                          _RequestTile(
                            name: (doc.data()
                                as Map<String, dynamic>)['fromName'],
                            text: 'Отправил запрос на обмен',
                            incoming: true,
                            documentId: doc.id,
                            otherUid:
                                (doc.data() as Map<String, dynamic>)['fromUid'],
                          ),
                      ],
                    );
                  },
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('participants', arrayContains: uid)
                      .snapshots(),
                  builder: (c, s) {
                    if (!s.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = s.data!.docs.toList()
                      ..sort((a, b) {
                        final x = (a.data() as Map)['updatedAt'] as Timestamp?;
                        final y = (b.data() as Map)['updatedAt'] as Timestamp?;
                        return (y?.millisecondsSinceEpoch ?? 0)
                            .compareTo(x?.millisecondsSinceEpoch ?? 0);
                      });
                    if (docs.isEmpty) {
                      return const Center(child: Text('Чатов пока нет'));
                    }
                    return ListView(children: [
                      for (final d in docs)
                        Builder(builder: (_) {
                          final m = d.data() as Map<String, dynamic>;
                          final otherUid = (m['participants'] as List)
                              .firstWhere((p) => p != uid);
                          final otherName =
                              (m['names'] as Map)[otherUid] ?? 'Студент';
                          return ListTile(
                            leading: CircleAvatar(
                                child: Text(otherName[0].toUpperCase())),
                            title: Text(otherName),
                            subtitle: Text(m['lastMessage'] ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                        otherUid: otherUid,
                                        otherName: otherName))),
                          );
                        }),
                    ]);
                  },
                ),
        ),
      ]),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String name;
  final String text;
  final bool incoming;
  final String? documentId;
  final String? otherUid;

  const _RequestTile({
    required this.name,
    required this.text,
    required this.incoming,
    this.documentId,
    this.otherUid,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE9E6FF),
                child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(text,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ]),
              ),
            ]),
            if (incoming) ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: documentId == null
                        ? null
                        : () => FirebaseFirestore.instance
                            .collection('requests')
                            .doc(documentId)
                            .update({'status': 'declined'}),
                    child: const Text('Отклонить'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: documentId == null
                        ? null
                        : () async {
                            await FirebaseFirestore.instance
                                .collection('requests')
                                .doc(documentId)
                                .update({'status': 'accepted'});
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                      otherUid: otherUid ?? '',
                                      otherName: name),
                                ),
                              );
                            }
                          },
                    child: const Text('Принять'),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      );
}
