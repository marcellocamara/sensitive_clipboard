import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensitive_clipboard/sensitive_clipboard.dart';

void main() {
  const MethodChannel sensitiveClipboardChannel = MethodChannel(
    'sensitive_clipboard',
  );
  const MethodChannel clipboardChannel = SystemChannels.platform;

  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  String clipboardContent = '';
  bool sensitiveClipboardPlatformChannelCalled = false;
  bool clipboardPlatformChannelCalled = false;

  setUp(() {
    clipboardContent = '';
    sensitiveClipboardPlatformChannelCalled = false;
    clipboardPlatformChannelCalled = false;

    messenger.setMockMethodCallHandler(sensitiveClipboardChannel, (
      MethodCall methodCall,
    ) async {
      sensitiveClipboardPlatformChannelCalled = true;
      if (methodCall.method == 'copy') {
        final args = methodCall.arguments as Map?;
        return args?['hideContent'];
      }
      return null;
    });

    messenger.setMockMethodCallHandler(clipboardChannel, (
      MethodCall methodCall,
    ) async {
      clipboardPlatformChannelCalled = true;

      if (methodCall.method == 'Clipboard.setData') {
        clipboardContent = methodCall.arguments['text'] ?? '';
        return null;
      } else if (methodCall.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboardContent};
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(sensitiveClipboardChannel, null);
    messenger.setMockMethodCallHandler(clipboardChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('SensitiveClipboard', () {
    test(
      'copy on Android returns hideContent value and does not call platform channel',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        clipboardContent = 'initial';

        final result = await SensitiveClipboard.copy('test', hideContent: true);

        expect(result, true);
        expect(sensitiveClipboardPlatformChannelCalled, true);
        expect(clipboardPlatformChannelCalled, false);
        expect(
          clipboardContent,
          'initial',
          reason:
              'Android should delegate to native channel only, without touching Clipboard',
        );
      },
    );

    test('copy on Android sends correct arguments to native side', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      String? capturedText;
      bool? capturedHideContent;

      messenger.setMockMethodCallHandler(sensitiveClipboardChannel, (
        MethodCall methodCall,
      ) async {
        if (methodCall.method == 'copy') {
          sensitiveClipboardPlatformChannelCalled = true;
          capturedText = methodCall.arguments['text'];
          capturedHideContent = methodCall.arguments['hideContent'];
          return true;
        }
        return null;
      });

      await SensitiveClipboard.copy('my secret text', hideContent: true);

      expect(capturedText, 'my secret text');
      expect(capturedHideContent, true);
      expect(sensitiveClipboardPlatformChannelCalled, true);
    });

    test('copy on Android handles null return from native channel', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      messenger.setMockMethodCallHandler(sensitiveClipboardChannel, (
        MethodCall methodCall,
      ) async {
        sensitiveClipboardPlatformChannelCalled = true;
        return null;
      });

      final result = await SensitiveClipboard.copy('text');
      expect(result, false);
      expect(sensitiveClipboardPlatformChannelCalled, true);
      expect(clipboardPlatformChannelCalled, false);
    });

    test('copy on iOS updates platform clipboard', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final result = await SensitiveClipboard.copy('ios text');
      expect(result, false);
      expect(sensitiveClipboardPlatformChannelCalled, false);
      expect(clipboardPlatformChannelCalled, true);
      expect(clipboardContent, 'ios text');

      clipboardPlatformChannelCalled = false;

      final data = await Clipboard.getData(Clipboard.kTextPlain);

      expect(data?.text, 'ios text');
      expect(sensitiveClipboardPlatformChannelCalled, false);
      expect(clipboardPlatformChannelCalled, true);
    });

    test('paste retrieves data from the mock clipboard state', () async {
      clipboardContent = 'data to paste';
      clipboardPlatformChannelCalled = false;

      final result = await SensitiveClipboard.paste();

      expect(result, 'data to paste');
      expect(clipboardPlatformChannelCalled, true);
      expect(sensitiveClipboardPlatformChannelCalled, false);

      clipboardContent = '';
      clipboardPlatformChannelCalled = false;

      final emptyResult = await SensitiveClipboard.paste();

      expect(emptyResult, '');
      expect(clipboardPlatformChannelCalled, true);
      expect(sensitiveClipboardPlatformChannelCalled, false);
    });
  });
}
