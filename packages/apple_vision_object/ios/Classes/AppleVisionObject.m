#import "AppleVisionObject.h"
#if __has_include(<apple_vision_object/apple_vision_object-Swift.h>)
#import <apple_vision_object/apple_vision_object-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apple_vision_object-Swift.h"
#endif

@implementation AppleVisionObject
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AppleVisionObjectPlugin registerWithRegistrar:registrar];
}
@end