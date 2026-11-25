import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../screens/video_player_screen.dart';

class VideoLessonCard extends StatelessWidget {
  final DemoVideoLesson lesson;
  final VoidCallback? onDelete;

  const VideoLessonCard({
    super.key,
    required this.lesson,
    this.onDelete,
  });

  void _open(BuildContext context) {
    final path = lesson.filePath;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Это пример урока без видеофайла')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(lesson: lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                color: lesson.category == 'Дизайн'
                    ? const Color(0xFFFFE6DD)
                    : const Color(0xFFDCD9FF),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.play_arrow, color: Color(0xFF5B55D6)),
                    ),
                    if (onDelete != null)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton.filledTonal(
                          tooltip: 'Удалить урок',
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.fileName ?? lesson.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Chip(label: Text(lesson.category)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
