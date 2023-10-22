#import "AppleVisionRecognizeText.h"
#if __has_include(<apple_vision_recognize_text/apple_vision_recognize_text-Swift.h>)
#import <apple_vision_recognize_text/apple_vision_recognize_text-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apple_vision_recognize_text-Swift.h"
#endif

@implementation AppleVisionRecognizeText
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AppleVisionRecognizeTextPlugin registerWithRegistrar:registrar];
}
@end