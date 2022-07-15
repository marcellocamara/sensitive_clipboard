#import "SensitiveClipboardPlugin.h"
#if __has_include(<sensitive_clipboard/sensitive_clipboard-Swift.h>)
#import <sensitive_clipboard/sensitive_clipboard-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sensitive_clipboard-Swift.h"
#endif

@implementation SensitiveClipboardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSensitiveClipboardPlugin registerWithRegistrar:registrar];
}
@end
