import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_object/apple_vision_object.dart';

/// The [AppleVisionObjectController] holds all the logic of this plugin,
/// where as the [AppleVisionObject] class is the frontend of this plugin.
class AppleVisionObjectController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/object');
  
  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<ObjectData>?> processImage(Uint8List image, Size imageSize,[ImageOrientation orientation = ImageOrientation.downMirrored]) async{
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
  List<ObjectData>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'object':
        List<ObjectData> data = [];
        for(int i = 0 ; i < event['data'].length;i++){
          data.add(
            ObjectFunctions.getObjectDataFromList(
              event['data'][i]
            )
          );
        }
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
