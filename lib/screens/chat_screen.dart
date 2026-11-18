import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String otherUid, otherName;
  const ChatScreen(
      {super.key, required this.otherUid, required this.otherName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _me = FirebaseAuth.instance.currentUser!;
  late final String _chatId = ([_me.uid, widget.otherUid]..sort()).join('_');
  late final DocumentReference _chat =
      FirebaseFirestore.instance.collection('chats').doc(_chatId);

  Future<void> _send() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();
    await _chat.set({
      'participants': [_me.uid, widget.otherUid],
      'names': {
        _me.uid: _me.displayName ?? 'Студент',
        widget.otherUid: widget.otherName
      },
      'lastMessage': t,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _chat.collection('messages').add({
      'senderId': _me.uid,
      'text': t,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.otherName)),
        body: Column(children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chat
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (c, s) {
                if (!s.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = s.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (c, i) {
                    final m = docs[i].data() as Map<String, dynamic>;
                    final mine = m['senderId'] == _me.uid;
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: mine
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: mine
                              ? null
                              : Border.all(color: const Color(0xFFE2E0EE)),
                        ),
                        child: Text(m['text'] ?? '',
                            style: TextStyle(
                                color: mine ? Colors.white : Colors.black87)),
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
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                        hintText: 'Сообщение...', border: OutlineInputBorder()),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ]),
            ),
          ),
        ]),
      );
}
