#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sensitive_clipboard.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sensitive_clipboard'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
Sensitive clipboard that wraps the original flutter clipboard.
                       DESC
  s.homepage         = 'https://github.com/marcellocamara/sensitive_clipboard'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'marcello.dev' => 'cellopcamara@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
