import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensitive_clipboard/sensitive_clipboard.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _text = 'Lorem Ipsum';
  bool _hideText = false;
  bool _loading = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> copyToClipboard() async {
    // Closes keyboard if its opened
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _loading = true);

    bool dataWasHiddenForAndroidAPI33;
    String text;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      dataWasHiddenForAndroidAPI33 = await SensitiveClipboard.copy(
        _text,
        hideContent: _hideText,
      );
      text = 'Successfully copied to Clipboard!\n'
          'But not hidden because it\'s not Android API 33';
    } on PlatformException {
      text = 'Ops! Something went wrong.';
      dataWasHiddenForAndroidAPI33 = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (!dataWasHiddenForAndroidAPI33) {
      // Shows snack bar into versions that are not the specific android version
      // The clipboard modal appears only on Android API 33+
      // You should not show dialog if is this version to avoid duplicated dialogs
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Sensitive Clipboard\nexample app',
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _hideText,
                  onChanged: (newValue) {
                    setState(() => _hideText = newValue!);
                  },
                ),
                const Text('Hide content'),
                const SizedBox(width: 24),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SizedBox(
                width: 150,
                child: TextFormField(
                  initialValue: _text,
                  textAlign: TextAlign.center,
                  onChanged: (String newText) {
                    setState(() => _text = newText);
                  },
                ),
              ),
            ),
            SizedBox(
              width: 135,
              height: 40,
              child: ElevatedButton(
                onPressed: _loading ? null : copyToClipboard,
                child: const Text('Copy'),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Click to copy the text\n'
              'from the TextField\n\n'
              'Data will be hidden if\n'
              'checkbox is checked',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
