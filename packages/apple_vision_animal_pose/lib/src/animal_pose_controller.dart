import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_animal_pose/apple_vision_animal_pose.dart';

/// The [AppleVisionAnimalPoseController] holds all the logic of this plugin,
/// where as the [AppleVisionAnimalPose] class is the frontend of this plugin.
class AppleVisionAnimalPoseController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/animal_pose');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  Future<List<AnimalPoseData>?> processImage(Uint8List image, Size imageSize) async{
    try {
      final Map<String, dynamic>? result = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':image,
          'width': imageSize.width,
          'height':imageSize.height
        },
      );
      return _convertData(result);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }
  
  /// Handles a returning event from the platform side
  List<AnimalPoseData>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'pose':
        List<AnimalPoseData> data = [];
        for(int i = 0; i < event['data'].length;i++){
          data.add(AnimalPoseData(AnimalPoseFunctions.getAniamlPoseDataFromList(event['data'][i]),Size(event['imageSize']['width'],event['imageSize']['height'])));
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
