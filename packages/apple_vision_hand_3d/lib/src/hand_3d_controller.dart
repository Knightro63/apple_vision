import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_hand_3d/apple_vision_hand_3d.dart';

/// The [AppleVisionHand3DController] holds all the logic of this plugin,
/// where as the [AppleVisionHand] class is the frontend of this plugin.
class AppleVisionHand3DController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/hand_3d');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<HandMesh>?> processImage(Uint8List image, Size imageSize,[ImageOrientation orientation = ImageOrientation.up]) async{
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

  /// Handles a returning event from the platform side
  List<HandMesh>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];
    switch (name) {
      case 'handMesh':
        List<HandMesh> data = [];
        //for(int i = 0; i < event['mesh'].length;i++){
          data.add(
            HandMesh.fromJson(event)
          );
        //}
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
