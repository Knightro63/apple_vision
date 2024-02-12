import 'dart:async';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Point{
  Point([
    this.x = 0,
    this.y = 0
  ]);
  
  final double x;
  final double y;

  @override
  String toString(){
    return [x,y].toString();
  }
}

class LiftedSubjectsData{
  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [format] the output format of the image
  /// 
  /// [crop] crop the image generated
  /// 
  /// [touchPoint] point on the image to get the subject
  /// 
  /// [backGround] the background image needs to be an image e.g.(png,jpg,jpeg,bmp,tiff)
  LiftedSubjectsData({
    required this.image,
    required this.imageSize,
    this.format = PictureFormat.png,
    this.backGround,
    this.orientation = ImageOrientation.up,
    this.touchPoint,
    this.crop = false
  });
  /// Image to be processed
  Uint8List image;
  Size imageSize; 
  PictureFormat format;
  ImageOrientation orientation;
  Uint8List? backGround;
  Point? touchPoint;
  bool crop;
}

/// The [AppleVisionliftSubjectsController] holds all the logic of this plugin,
/// where as the [AppleVisionliftSubjects] class is the frontend of this plugin.
class AppleVisionliftSubjectsController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/lift_subjects');

  /// Process the image using apple vision and return the requested information or null value
  Future<Uint8List?> processImage(LiftedSubjectsData data) async{
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':data.image,
          'width': data.imageSize.width,
          'height':data.imageSize.height,
          'format': data.format.name,
          'background': data.backGround,
          'orientation': data.orientation.name,
          'x': data.touchPoint?.x,
          'y': data.touchPoint?.y,
          'crop': data.crop
        },
      );
      return _convertData(result);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }

  /// Handles a returning event from the platform side
  Uint8List? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];
    switch (name) {
      case 'lift':
        return event['data'];
      case 'noData':
        break;
      case 'done':
        break;
      case 'error':
        throw AppleVisionException(
          errorCode: AppleVisionErrorCode.genericError,
          errorDetails: AppleVisionErrorDetails(message: event['message'] as String?),
        );
      default:
        throw UnimplementedError(name as String?);
    }
    return null;
  }
}
