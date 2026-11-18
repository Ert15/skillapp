import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_mode.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});
  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  String _type = 'offer';
  final _skill = TextEditingController();
  final _ret = TextEditingController();
  final _desc = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    if (_skill.text.trim().isEmpty || _ret.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заполни навык и что взамен')));
      return;
    }
    if (previewMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Публикация доступна после подключения Firebase'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final u = FirebaseAuth.instance.currentUser!;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
      final savedName = (userDoc.data()?['name'] as String?)?.trim();
      final authName = u.displayName?.trim();
      final authorName =
          authName != null && authName.isNotEmpty && authName != 'Студент'
              ? authName
              : (savedName?.isNotEmpty == true ? savedName : authName);
      if (authorName == null || authorName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Сначала укажи имя в профиле')),
          );
        }
        return;
      }

      await FirebaseFirestore.instance.collection('offers').add({
        'authorId': u.uid,
        'authorName': authorName,
        'type': _type,
        'skill': _skill.text.trim(),
        'wantInReturn': _ret.text.trim(),
        'description': _desc.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Не удалось сохранить баннер')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffer = _type == 'offer';
    return Scaffold(
      appBar: AppBar(title: const Text('Создать объявление')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Что вы хотите сделать?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'offer', label: Text('Могу помочь')),
            ButtonSegment(value: 'request', label: Text('Хочу научиться')),
          ],
          selected: {_type},
          onSelectionChanged: (v) => setState(() => _type = v.first),
        ),
        const SizedBox(height: 16),
        TextField(
            controller: _skill,
            decoration: InputDecoration(
                labelText: isOffer
                    ? 'Что умею (напр. Математика)'
                    : 'Чему хочу научиться',
                border: const OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: _ret,
            decoration: InputDecoration(
                labelText: isOffer
                    ? 'Что хочу взамен (История / Деньги)'
                    : 'Что могу дать взамен',
                border: const OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Описание', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Публикуем...'),
                  ],
                )
              : const Text('Опубликовать'),
        ),
      ]),
    );
  }
}
