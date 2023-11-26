import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_face/apple_vision_face.dart';

/// The [AppleVisionFaceController] holds all the logic of this plugin,
/// where as the [AppleVisionFace] class is the frontend of this plugin.
class AppleVisionFaceController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/face');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<FaceData>?> processImage(Uint8List image, Size imageSize,[ImageOrientation orientation = ImageOrientation.downMirrored]) async{
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

  /// Faceles a returning event from the platform side
  List<FaceData>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'face':
        List<FaceData> data = [];
        for(int i = 0; i < event['data'].length;i++){
          data.add(
            FaceData(
              marks:FaceFunctions.getFaceDataFromList(event['data'][i]['data']),
              imageSize:Size(event['imageSize']['width'],event['imageSize']['height']),
              yaw: event['data'][i]['orientation']['yaw'],
              pitch: event['data'][i]['orientation']['pitch'],
              roll: event['data'][i]['orientation']['roll'],
              quality: event['data'][i]['orientation']['quality']
            )
          );
        }
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
