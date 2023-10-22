#import "AppleVisionImageClassification.h"
#if __has_include(<apple_vision_image_classification/apple_vision_image_classification-Swift.h>)
#import <apple_vision_image_classification/apple_vision_image_classification-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apple_vision_image_classification-Swift.h"
#endif

@implementation AppleVisionImageClassification
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AppleVisionImageClassificationPlugin registerWithRegistrar:registrar];
}
@end