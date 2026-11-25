import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/demo_store.dart';
import 'package:skillswap/main.dart';
import 'package:skillswap/screens/create_video_lesson_screen.dart';

void main() {
  testWidgets('registration opens the app and logout returns to welcome',
      (tester) async {
    await tester.pumpWidget(const SkillSwapApp());

    await tester.tap(find.text('СОЗДАТЬ АККАУНТ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Алия');
    await tester.enterText(find.byType(TextField).at(1), 'aliya@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');
    await tester.tap(find.text('СОЗДАТЬ АККАУНТ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Алия'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Выйти'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(find.text('Меняйтесь навыками,\nа не деньгами'), findsOneWidget);
  });

  testWidgets('creates a card that appears in the feed', (tester) async {
    await _signUp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Помощь с Flutter');
    await tester.enterText(find.byType(TextField).at(1), 'Английский');
    await tester.enterText(find.byType(TextField).at(2), 'Помогу с проектом');
    await tester.tap(find.text('Опубликовать'));
    await tester.pumpAndSettle();

    expect(find.text('Помощь с Flutter'), findsOneWidget);
  });

  testWidgets('opens a chat and sends a local message', (tester) async {
    await _signUp(tester);

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Принять').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Отправить'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Сообщение для проверки');
    await tester.tap(find.byTooltip('Отправить'));
    await tester.pumpAndSettle();

    expect(find.text('Сообщение для проверки'), findsOneWidget);
  });

  testWidgets('opens an existing chat from the chats tab', (tester) async {
    await _signUp(tester);

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<int>),
        matching: find.text('Чаты'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Отправить'), findsOneWidget);
  });

  testWidgets('adds a picked video lesson to the local list', (tester) async {
    final store = DemoStore();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateVideoLessonScreen(
                    store: store,
                    pickVideo: () async => const SelectedVideoFile(
                      name: 'lesson.mp4',
                      path: r'C:\lesson.mp4',
                    ),
                  ),
                ),
              ),
              child: const Text('Открыть добавление'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть добавление'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Урок Flutter');
    await tester.enterText(find.byType(TextField).at(1), 'IT');
    await tester.enterText(find.byType(TextField).at(2), 'Описание');
    await tester.tap(find.text('Выбрать видео на устройстве'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Опубликовать урок'));
    await tester.pumpAndSettle();

    expect(store.videoLessons.first.title, 'Урок Flutter');
    expect(store.videoLessons.first.fileName, 'lesson.mp4');
  });
}

Future<void> _signUp(WidgetTester tester) async {
  await tester.pumpWidget(const SkillSwapApp());
  await tester.tap(find.text('СОЗДАТЬ АККАУНТ'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), 'Алия');
  await tester.enterText(find.byType(TextField).at(1), 'aliya@example.com');
  await tester.enterText(find.byType(TextField).at(2), 'password');
  await tester.tap(find.text('СОЗДАТЬ АККАУНТ'));
  await tester.pumpAndSettle();
}
