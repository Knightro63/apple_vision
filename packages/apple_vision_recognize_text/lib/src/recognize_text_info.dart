import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// A value that determines whether the request prioritizes accuracy or speed in text recognition.
enum RecognitionLevel {fast,accurate}
enum Dispatch {defaultQueue,background,unspecified,userInitiated,userInteractive,utility}

class RecognizeTextData{
  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [dispatch] the ability to use this in the background
  /// 
  /// [recognitionLevel] the speed of determining the information
  /// 
  /// [orientation] the orientation of the image being processed
  /// 
  /// [languages] An array of locale to detect, in priority order.
  /// 
  /// [automaticallyDetectsLanguage] A Boolean value that indicates whether to attempt detecting the language to use the appropriate model for recognition and language correction. (Only available in iOS 16.0 or newer.)
  RecognizeTextData({
    required this.image,
    required this.imageSize,
    this.orientation = ImageOrientation.up,
    this.dispatch = Dispatch.defaultQueue,
    this.recognitionLevel = RecognitionLevel.fast,
    this.automaticallyDetectsLanguage = false,
    this.languages
  });

  Uint8List image; 
  Size imageSize;
  Dispatch dispatch;
  RecognitionLevel recognitionLevel;
  ImageOrientation orientation;
  bool automaticallyDetectsLanguage;
  List<Locale>? languages;
}