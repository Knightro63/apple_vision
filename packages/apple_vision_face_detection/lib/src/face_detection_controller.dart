import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';

/// The [AppleVisionFaceDetectionController] holds all the logic of this plugin,
/// where as the [AppleVisionObject] class is the frontend of this plugin.
class AppleVisionFaceDetectionController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/face_detection');
  
  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<Rect>?> processImage(Uint8List image, Size imageSize,[ImageOrientation orientation = ImageOrientation.downMirrored]) async{
    try {
      final data = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':image,
          'width': imageSize.width,
          'height':imageSize.height,
          'orientation': orientation.name
        },
      );
      return _convertData(data);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }

  /// Objectles a returning event from the platform side
  List<Rect>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'faceDetect':
        List<Rect> data = FaceDetectFunctions.getFaceDataFromList(
          event['data']
        );
        return data;
      case 'error':
        throw AppleVisionException(
          errorCode: AppleVisionErrorCode.genericError,
          errorDetails: AppleVisionErrorDetails(message: event['message'] as String?),
        );
      default:
        throw UnimplementedError(name as String?);
    }
  }
}

/// A class that converts the information from apple vision to dart
class FaceDetectFunctions{
  /// Convert rect data from apple vision to usable dart data
  static List<Rect> getFaceDataFromList(List<Object?> faces){
    List<Rect> data = [];
    for(int i = 0; i < faces.length; i++){
      Map map = faces[i] as Map;
      data.add(
        Rect.fromCenter(center: Offset(map['origin']['x'],map['origin']['y']),width: map['width'],height: map['height'])
      );
    }

    return data;
  }
}
