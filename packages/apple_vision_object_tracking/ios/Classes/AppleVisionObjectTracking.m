#import "AppleVisionObjectTracking.h"
#if __has_include(<apple_vision_object_tracking/apple_vision_object_tracking-Swift.h>)
#import <apple_vision_object_tracking/apple_vision_object_tracking-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apple_vision_object_tracking-Swift.h"
#endif

@implementation AppleVisionObjectTracking
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AppleVisionObjectTrackingPlugin registerWithRegistrar:registrar];
}
@end