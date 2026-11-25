import 'package:flutter/foundation.dart';

class DemoOffer {
  final String id;
  final String authorId;
  final String authorName;
  final String type;
  final String skill;
  final String wantInReturn;
  final String description;

  const DemoOffer({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.type,
    required this.skill,
    required this.wantInReturn,
    this.description = '',
  });

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'type': type,
        'skill': skill,
        'wantInReturn': wantInReturn,
        'description': description,
      };
}

class DemoVideoLesson {
  final String id;
  final String authorId;
  final String title;
  final String authorName;
  final String category;
  final String description;
  final String? fileName;
  final String? filePath;

  const DemoVideoLesson({
    required this.id,
    required this.authorId,
    required this.title,
    required this.authorName,
    required this.category,
    this.description = '',
    this.fileName,
    this.filePath,
  });
}

class DemoRequest {
  final String id;
  final String otherUid;
  final String otherName;
  final String text;
  final bool incoming;
  String status;

  DemoRequest({
    required this.id,
    required this.otherUid,
    required this.otherName,
    required this.text,
    required this.incoming,
    this.status = 'pending',
  });
}

class DemoMessage {
  final String text;
  final String senderId;
  final DateTime sentAt;

  const DemoMessage({
    required this.text,
    required this.senderId,
    required this.sentAt,
  });

  bool get isMine => senderId == DemoStore.currentUserId;
}

class DemoChat {
  final String id;
  final String otherUid;
  final String otherName;
  final List<DemoMessage> messages;

  DemoChat({
    required this.id,
    required this.otherUid,
    required this.otherName,
    List<DemoMessage> messages = const [],
  }) : messages = List.of(messages);

  String get lastMessage => messages.isEmpty ? '' : messages.last.text;
}

class DemoStore extends ChangeNotifier {
  static const currentUserId = 'local-user';

  String currentUserName = 'Сатыбалды Д.';

  final List<DemoOffer> _offers = [
    const DemoOffer(
      id: 'preview-maria',
      authorId: 'preview-maria',
      authorName: 'Мария',
      type: 'offer',
      skill: 'Английский язык',
      wantInReturn: 'Помощь с математикой',
      description: 'Помогу разговориться и разобраться с грамматикой.',
    ),
    const DemoOffer(
      id: 'preview-ivan',
      authorId: 'preview-ivan',
      authorName: 'Иван',
      type: 'request',
      skill: 'Хочу научиться играть на гитаре',
      wantInReturn: 'Могу помочь с программированием',
      description: 'Ищу занятия для начинающего.',
    ),
  ];

  final List<DemoVideoLesson> _videoLessons = [
    const DemoVideoLesson(
      id: 'lesson-math',
      authorId: 'preview-ersultan',
      title: 'Производная за 10 минут',
      authorName: 'Ерсултан А.',
      category: 'Математика',
      description: 'Короткий вводный урок по производным.',
    ),
    const DemoVideoLesson(
      id: 'lesson-design',
      authorId: 'preview-maria',
      title: 'Основы дизайна',
      authorName: 'Мария К.',
      category: 'Дизайн',
      description: 'Основы композиции и визуальной иерархии.',
    ),
  ];

  final List<DemoRequest> _requests = [
    DemoRequest(
      id: 'request-maria',
      otherUid: 'preview-maria',
      otherName: 'Мария',
      text: 'Хочет обменяться английским',
      incoming: true,
    ),
    DemoRequest(
      id: 'request-ivan',
      otherUid: 'preview-ivan',
      otherName: 'Иван',
      text: 'Предлагает помощь с программированием',
      incoming: false,
    ),
  ];

  final List<DemoChat> _chats = [
    DemoChat(
      id: 'chat-maria',
      otherUid: 'preview-maria',
      otherName: 'Мария',
      messages: [
        DemoMessage(
          text: 'Привет! Давай обменяемся навыками.',
          senderId: 'preview-maria',
          sentAt: DateTime(2025, 1, 1, 10),
        ),
        DemoMessage(
          text: 'Отличная идея, расскажи подробнее.',
          senderId: currentUserId,
          sentAt: DateTime(2025, 1, 1, 10, 5),
        ),
      ],
    ),
  ];

  final Set<String> _favoriteIds = {};
  int _nextId = 0;

  List<DemoOffer> get offers => List.unmodifiable(_offers);
  List<DemoVideoLesson> get videoLessons => List.unmodifiable(_videoLessons);
  List<DemoRequest> get requests => List.unmodifiable(
      _requests.where((request) => request.status == 'pending'));
  List<DemoChat> get chats => List.unmodifiable(_chats);
  List<DemoOffer> get favorites => List.unmodifiable(
      _offers.where((offer) => _favoriteIds.contains(offer.id)));
  List<DemoOffer> get myOffers => List.unmodifiable(
      _offers.where((offer) => offer.authorId == currentUserId));
  List<DemoVideoLesson> get myVideoLessons => List.unmodifiable(
      _videoLessons.where((lesson) => lesson.authorId == currentUserId));

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  void setCurrentUserName(String name) {
    currentUserName = name;
    notifyListeners();
  }

  void addOffer({
    required String type,
    required String skill,
    required String wantInReturn,
    required String description,
  }) {
    _offers.insert(
      0,
      DemoOffer(
        id: _newId('offer'),
        authorId: currentUserId,
        authorName: currentUserName,
        type: type,
        skill: skill,
        wantInReturn: wantInReturn,
        description: description,
      ),
    );
    notifyListeners();
  }

  void removeOffer(String id) {
    _offers.removeWhere((offer) => offer.id == id);
    _favoriteIds.remove(id);
    notifyListeners();
  }

  void addVideoLesson({
    required String title,
    required String category,
    required String description,
    required String fileName,
    required String filePath,
  }) {
    _videoLessons.insert(
      0,
      DemoVideoLesson(
        id: _newId('lesson'),
        authorId: currentUserId,
        title: title,
        authorName: currentUserName,
        category: category,
        description: description,
        fileName: fileName,
        filePath: filePath,
      ),
    );
    notifyListeners();
  }

  void removeVideoLesson(String id) {
    _videoLessons.removeWhere((lesson) => lesson.id == id);
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (!_favoriteIds.add(id)) _favoriteIds.remove(id);
    notifyListeners();
  }

  DemoChat openChat(String otherUid, String otherName) {
    for (final chat in _chats) {
      if (chat.otherUid == otherUid) return chat;
    }
    final chat = DemoChat(
      id: _newId('chat'),
      otherUid: otherUid,
      otherName: otherName,
    );
    _chats.insert(0, chat);
    notifyListeners();
    return chat;
  }

  DemoChat? chatById(String id) {
    for (final chat in _chats) {
      if (chat.id == id) return chat;
    }
    return null;
  }

  void sendMessage(String chatId, String text) {
    final message = text.trim();
    if (message.isEmpty) return;
    final chat = chatById(chatId);
    if (chat == null) {
      throw StateError('Чат не найден: $chatId');
    }
    chat.messages.add(
      DemoMessage(
        text: message,
        senderId: currentUserId,
        sentAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  DemoChat acceptRequest(String requestId) {
    DemoRequest? request;
    for (final item in _requests) {
      if (item.id == requestId && item.status == 'pending') {
        request = item;
        break;
      }
    }
    if (request == null) {
      throw StateError('Запрос не найден: $requestId');
    }
    request.status = 'accepted';
    final chat = openChat(request.otherUid, request.otherName);
    notifyListeners();
    return chat;
  }

  void declineRequest(String requestId) {
    DemoRequest? request;
    for (final item in _requests) {
      if (item.id == requestId) {
        request = item;
        break;
      }
    }
    if (request == null) {
      throw StateError('Запрос не найден: $requestId');
    }
    request.status = 'declined';
    notifyListeners();
  }
}
