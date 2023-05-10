import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SensitiveClipboard {
  SensitiveClipboard._();

  static const MethodChannel _channel =
      const MethodChannel('sensitive_clipboard');

  /// Copies string into the clipboard
  /// Returns true only if sensitive content has been hidden - for Android API 33+
  static Future<bool> copy(String? text, {bool hideContent = true}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Sensitive clipboard
      final copyResult = await _channel.invokeMethod<bool>(
        'copy',
        {'text': text, 'hideContent': hideContent},
      );
      return Future.value(copyResult);
    } else {
      // Flutter's default clipboard
      await Clipboard.setData(ClipboardData(text: text ?? ''));
      return Future.value(false);
    }
  }

  /// Pastes string retrieved from the clipboard
  static Future<String> paste() async {
    // Flutter's default clipboard
    ClipboardData? data = await Clipboard.getData('text/plain');
    return data?.text ?? '';
  }
}
