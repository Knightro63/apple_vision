#import "AppleVisionScanner.h"
#if __has_include(<apple_vision_scanner/apple_vision_scanner-Swift.h>)
#import <apple_vision_scanner/apple_vision_scanner-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apple_vision_scanner-Swift.h"
#endif

@implementation AppleVisionScanner
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AppleVisionScannerPlugin registerWithRegistrar:registrar];
}
@end