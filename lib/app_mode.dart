import 'package:flutter/foundation.dart';

const previewMode =
    kDebugMode && bool.fromEnvironment('PREVIEW_MODE', defaultValue: false);
