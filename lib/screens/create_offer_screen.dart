import 'package:flutter/material.dart';
import '../demo_store.dart';

class CreateOfferScreen extends StatefulWidget {
  final DemoStore store;

  const CreateOfferScreen({
    super.key,
    required this.store,
  });

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  String _type = 'offer';
  final _skill = TextEditingController();
  final _ret = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _skill.dispose();
    _ret.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    final skill = _skill.text.trim();
    final wantInReturn = _ret.text.trim();
    if (skill.isEmpty || wantInReturn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполни навык и что взамен')),
      );
      return;
    }
    widget.store.addOffer(
      type: _type,
      skill: skill,
      wantInReturn: wantInReturn,
      description: _desc.text.trim(),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isOffer = _type == 'offer';
    return Scaffold(
      appBar: AppBar(title: const Text('Создать объявление')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Что вы хотите сделать?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'offer', label: Text('Могу помочь')),
              ButtonSegment(value: 'request', label: Text('Хочу научиться')),
            ],
            selected: {_type},
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _skill,
            decoration: InputDecoration(
              labelText: isOffer
                  ? 'Что умею (напр. Математика)'
                  : 'Чему хочу научиться',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ret,
            decoration: InputDecoration(
              labelText: isOffer
                  ? 'Что хочу взамен (История / Деньги)'
                  : 'Что могу дать взамен',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Описание'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _save,
            child: const Text('Опубликовать'),
          ),
          const SizedBox(height: 8),
          Text(
            'Карточка будет доступна только в этом демо-запуске.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
