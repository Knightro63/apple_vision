#import "AppleVisionHand.h"
#if __has_include(<apple_vision_hand/apple_vision_hand-Swift.h>)
#import <apple_vision_hand/apple_vision_hand-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apple_vision_hand-Swift.h"
#endif

@implementation AppleVisionHand
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AppleVisionHandPlugin registerWithRegistrar:registrar];
}
@end