import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../demo_store.dart';

class SelectedVideoFile {
  final String name;
  final String path;

  const SelectedVideoFile({required this.name, required this.path});
}

typedef VideoFilePicker = Future<SelectedVideoFile?> Function();

class CreateVideoLessonScreen extends StatefulWidget {
  final DemoStore store;
  final VideoFilePicker? pickVideo;

  const CreateVideoLessonScreen({
    super.key,
    required this.store,
    this.pickVideo,
  });

  @override
  State<CreateVideoLessonScreen> createState() =>
      _CreateVideoLessonScreenState();
}

class _CreateVideoLessonScreenState extends State<CreateVideoLessonScreen> {
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  SelectedVideoFile? _video;
  bool _picking = false;

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    setState(() => _picking = true);
    try {
      final selected = widget.pickVideo == null
          ? await _pickFromDevice()
          : await widget.pickVideo!();
      if (selected == null || !mounted) return;
      setState(() => _video = selected);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось выбрать видео: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<SelectedVideoFile?> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final selected = result.files.single;
    final path = selected.path;
    if (path == null) {
      throw StateError('Не удалось получить путь к видеофайлу');
    }
    return SelectedVideoFile(name: selected.name, path: path);
  }

  void _publish() {
    final title = _title.text.trim();
    final category = _category.text.trim();
    final video = _video;
    if (title.isEmpty || category.isEmpty || video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполни название, тему и выбери видео')),
      );
      return;
    }
    widget.store.addVideoLesson(
      title: title,
      category: category,
      description: _description.text.trim(),
      fileName: video.name,
      filePath: video.path,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Добавить видеоурок')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Название урока'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Тема'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _picking ? null : _pickVideo,
              icon: _picking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.video_library_outlined),
              label: Text(_video?.name ?? 'Выбрать видео на устройстве'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _picking ? null : _publish,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Опубликовать урок'),
            ),
            const SizedBox(height: 8),
            Text(
              'В демо-режиме урок доступен только на этом устройстве и пока приложение запущено.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
