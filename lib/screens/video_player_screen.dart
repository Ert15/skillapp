import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../demo_store.dart';

class VideoPlayerScreen extends StatefulWidget {
  final DemoVideoLesson lesson;

  const VideoPlayerScreen({super.key, required this.lesson});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialized;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.lesson.filePath!));
    _initialized = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<void>(
              future: _initialized,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Не удалось открыть видео: ${snapshot.error}');
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              widget.lesson.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('${widget.lesson.category} · ${widget.lesson.authorName}'),
            if (widget.lesson.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(widget.lesson.description),
            ],
          ],
        ),
      );
}
