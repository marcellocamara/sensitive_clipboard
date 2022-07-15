import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensitive_clipboard/sensitive_clipboard.dart';

void main() {
  const MethodChannel channel = MethodChannel('sensitive_clipboard');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return methodCall.arguments['hideContent'];
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('copyText', () async {
    expect(await SensitiveClipboard.copy(null), true);
    expect(await SensitiveClipboard.copy(null, hideContent: false), false);
    expect(await SensitiveClipboard.copy(''), true);
    expect(await SensitiveClipboard.copy('', hideContent: false), false);
    expect(await SensitiveClipboard.copy('123456'), true);
    expect(await SensitiveClipboard.copy('123456', hideContent: false), false);
  });
}
