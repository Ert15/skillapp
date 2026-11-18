# SkillSwap — MVP (Flutter + Firebase)

## Запуск
1. Установи Flutter и Firebase CLI, затем:  `dart pub global activate flutterfire_cli`
2. Создай проект в https://console.firebase.google.com
   - Authentication → Sign-in method → включи **Email/Password**
   - Firestore Database → Create database (test mode на старте)
3. В корне проекта:
   ```
   flutter create .          # создаст android/ios папки, файлы lib/ не тронет
   flutter pub get
   flutterfire configure     # создаст lib/firebase_options.dart
   flutter run
   ```
   В debug-режиме приложение по умолчанию подключается к Firebase и показывает экран входа. Для предпросмотра без Firebase запусти `flutter run --dart-define=PREVIEW_MODE=true`.
4. Firestore → Rules → вставь содержимое `firestore.rules` → Publish.
5. При первом запуске ленты Firestore может попросить создать индекс — в консоли (debug) появится ссылка, нажми на неё.

## Что внутри
- Регистрация / логин с сохранением имени и email в Firebase Auth и Firestore
- Главная: баннеры «Могу / Хочу», фильтр, кнопка «+»
- Создание баннера → Firestore (`offers`)
- Добавление и удаление баннеров из избранного → Firestore (`users/{uid}/favorites`)
- Чаты 1-на-1 (`chats/{id}/messages`)
- Избранное (`users/{uid}/favorites`)
- Профиль: мои баннеры, удаление, выход
