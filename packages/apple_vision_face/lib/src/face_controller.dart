import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_face/apple_vision_face.dart';

/// The [AppleVisionFaceController] holds all the logic of this plugin,
/// where as the [AppleVisionFace] class is the frontend of this plugin.
class AppleVisionFaceController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/face');

  Future<FaceData?> process(Uint8List image, Size imageSize) async{
    try {
      final data = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':image,
          'width': imageSize.width,
          'height':imageSize.height
        },
      );
      return _convertData(data);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }

  /// Faceles a returning event from the platform side
  FaceData? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'face':
        FaceData data = FaceData(
          marks:FaceFunctions().getFaceDataFromList(event['data']),
          imageSize:Size(event['imageSize']['width'],event['imageSize']['height']),
          yaw: event['orientation']['yaw'],
          pitch: event['orientation']['pitch'],
          roll: event['orientation']['roll'],
          quality: event['orientation']['quality']
        );
        return data;
      case 'noData':
        break;
      case 'done':
        break;
      case 'error':
        throw AppleVisionException(
          errorCode: AppleVisionErrorCode.genericError,
          errorDetails: AppleVisionErrorDetails(message: event["message"] as String?),
        );
      default:
        throw UnimplementedError(name as String?);
    }

    return null;
  }
}
