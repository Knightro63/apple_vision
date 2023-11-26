import 'dart:async';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum PictureFormat{jpg,jpeg,tiff,bmp,png,raw}
enum SelfieQuality{fast,balanced,accurate}

class SelfieSegmentationData{
  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [format] the output format of the image
  /// 
  /// [quality] the quality of the output image
  /// 
  /// [backGround] the background image needs to be an image e.g.(png,jpg,jpeg,bmp,tiff)
  SelfieSegmentationData({
    required this.image,
    required this.imageSize,
    this.format = PictureFormat.tiff,
    this.quality = SelfieQuality.fast,
    this.backGround,
    this.orientation = ImageOrientation.up
  });
  /// Image to be processed
  Uint8List image;
  Uint8List? backGround;
  Size imageSize; 
  PictureFormat format;
  SelfieQuality quality;
  ImageOrientation orientation;
}

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
  /// 
  /// [orientation] The orientation of the image
  Future<List<Uint8List?>?> processImage(SelfieSegmentationData data) async{
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':data.image,
          'width': data.imageSize.width,
          'height':data.imageSize.height,
          'format': data.format.name,
          'quality': data.quality.index,
          'background': data.backGround,
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
