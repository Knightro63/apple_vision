import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';

class ImageDepthData{
  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [format] the output format of the image
  ImageDepthData({
    required this.image,
    required this.imageSize,
    this.format = PictureFormat.png,
    this.orientation = ImageOrientation.up,
    this.confidence = 0.75
  });
  /// Image to be processed
  Uint8List image;
  Size imageSize;
  double confidence;
  PictureFormat format;
  ImageOrientation orientation;
}

/// The [AppleVisionImageDepthController] holds all the logic of this plugin,
/// where as the [AppleVisionObject] class is the frontend of this plugin.
class AppleVisionImageDepthController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/image_depth');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<Uint8List?> processImage(ImageDepthData data) async{
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':data.image,
          'width': data.imageSize.width,
          'height':data.imageSize.height,
          'confidence': data.confidence,
          'orientation': data.orientation.name,
          'format': data.format.name,
        }
      );
      return _convertData(result);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }

  /// Objectles a returning event from the platform side
  Uint8List? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];
    switch (name) {
      case 'imageDepth':
        return event['data'] == null && event['data'].isEmpty()?null:event['data']?.first;
      case 'error':
        throw AppleVisionException(
          errorCode: AppleVisionErrorCode.genericError,
          errorDetails: AppleVisionErrorDetails(message: event['message'] as String?),
        );
      case 'noData':
        return null;
      default:
        throw UnimplementedError(name as String?);
    }
  }
}
