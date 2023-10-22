import 'dart:async';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum PictureFormat{jpg,jpeg,tiff,bmp,png}

/// The [AppleVisionSelfieController] holds all the logic of this plugin,
/// where as the [AppleVisionSelfie] class is the frontend of this plugin.
class AppleVisionSelfieController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/selfie');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  Future<List<Uint8List?>?> processImage(Uint8List image, Size imageSize, [PictureFormat format = PictureFormat.tiff]) async{
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':image,
          'width': imageSize.width,
          'height':imageSize.height,
          'format': format.name
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
      case 'selfie':
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
