import 'dart:async';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum SaliencyType{attention,object}

class SaliencySegmentationData{
  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [format] the output format of the image
  SaliencySegmentationData({
    required this.image,
    required this.imageSize,
    this.format = PictureFormat.png,
    this.orientation = ImageOrientation.up,
    this.type = SaliencyType.attention
  });
  /// Image to be processed
  Uint8List image;
  Size imageSize;
  SaliencyType type;
  PictureFormat format;
  ImageOrientation orientation;
}

/// The [AppleVisionSaliencyController] holds all the logic of this plugin,
/// where as the [AppleVisionSaliency] class is the frontend of this plugin.
class AppleVisionSaliencyController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/saliency');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<Uint8List?>?> processImage(SaliencySegmentationData data) async{
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':data.image,
          'width': data.imageSize.width,
          'height':data.imageSize.height,
          'format': data.format.name,
          'type': data.type.name,
          'orientation': data.orientation.name
        },
      );
      return _convertData(result);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }

  /// Handles a returning event from the platform side
  List<Uint8List?>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];
    switch (name) {
      case 'saliency':
        List<Uint8List?> data = [];
        for(int i = 0; i < event['data'].length;i++){
          data.add(event['data'][i]);
        }
        return data;
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
