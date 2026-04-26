import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SensitiveClipboard {
  SensitiveClipboard._();

  static const MethodChannel _channel = MethodChannel('sensitive_clipboard');

  /// Copies a string to the clipboard
  /// Returns true only if sensitive content is hidden (Android API 33+)
  static Future<bool> copy(String? text, {bool hideContent = true}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Sensitive clipboard
      final copyResult = await _channel.invokeMethod<bool>('copy', {
        'text': text,
        'hideContent': hideContent,
      });
      return copyResult ?? false;
    } else {
      // Flutter's default clipboard
      await Clipboard.setData(ClipboardData(text: text ?? ''));
      return false;
    }
  }

  /// Pastes a string previously copied to the clipboard
  static Future<String> paste() async {
    // Flutter's default clipboard
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text ?? '';
  }
}
