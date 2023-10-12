#import "AppleVisionPose.h"
#if __has_include(<apple_vision_pose/apple_vision_pose-Swift.h>)
#import <apple_vision_pose/apple_vision_pose-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apple_vision_pose-Swift.h"
#endif

@implementation AppleVisionPose
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AppleVisionPosePlugin registerWithRegistrar:registrar];
}
@end