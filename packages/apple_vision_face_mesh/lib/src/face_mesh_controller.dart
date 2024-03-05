import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_face_mesh/apple_vision_face_mesh.dart';

/// The [AppleVisionFaceMeshController] holds all the logic of this plugin,
/// where as the [AppleVisionFaceMesh] class is the frontend of this plugin.
class AppleVisionFaceMeshController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/face_mesh');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<FaceMesh>?> processImage(Uint8List image, Size imageSize,[ImageOrientation orientation = ImageOrientation.up]) async{
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
  List<FaceMesh>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'faceMesh':
        List<FaceMesh> data = [];
        for(int i = 0; i < event['data'].length;i++){
          data.add(
            FaceMesh.fromJson(event['data'][i])
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
