# sensitive_clipboard_example

A clipboard plugin that allows to copy sensitive content to clipboard using the new param sensitive into the Android 13 (API 33).

For more information about it, read the original [documentation](https://developer.android.com/about/versions/13/features/copy-paste#sensitive-content).

![example-gif](/Users/cello/Desktop/sensitive_clipboard/example/assets/example.gif)

## Getting Started

This project is a anticipated plugin to avoid sensitive data be shown on Android 13, until Flutter's official package allows to do the same.

This works with Android and iOS. The main objective is to wrap the original clipboard, allowing to hide sensitive content only for Android 13. If the default platform is iOS, the original clipboard from Flutter will be called.

Because the Android 13 has a pop up dialog, showing the copied content, we need to [avoid show feedback message](https://developer.android.com/about/versions/13/features/copy-paste#duplicate-notifications) on bottom of your page. For this, you can use the return of the copy method, to guarantee if the sensitive content was hidden for Android 13 and pop up was shown. If the method returns true, the platform is the Android 13, and the pop up shows up - and you should not show your message. If returns false, you can show your feedback message normally.

## Usage

#### 1) Add to your package's pubspec.yaml file:

```yaml
dependencies:
  sensitive_clipboard: [latest version]
```

#### 2) Install

```
$ flutter pub get
```

#### 3) Import

```dart
import 'package:sensitive_clipboard/sensitive_clipboard.dart';
```

#### 4) Use

```dart
SensitiveClipboard.copy('Sensitive-Content');
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
