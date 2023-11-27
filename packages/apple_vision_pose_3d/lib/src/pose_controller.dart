import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:apple_vision_pose_3d/apple_vision_pose_3d.dart';

/// The [AppleVisionPose3DController] holds all the logic of this plugin,
/// where as the [AppleVisionPose3D] class is the frontend of this plugin.
class AppleVisionPose3DController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/pose3d');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<PoseData3D>?> processImage(Uint8List image, Size imageSize,[ImageOrientation orientation = ImageOrientation.up]) async{
    try {
      final Map<String, dynamic>? result = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':image,
          'width': imageSize.width,
          'height':imageSize.height,
          'orientation': orientation.name
        },
      );
      return _convertData(result);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }
  
  /// Handles a returning event from the platform side
  List<PoseData3D>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];
    
    switch (name) {
      case 'pose3d':
        List<PoseData3D> data = [];
        for(int i = 0; i < event['data'].length;i++){
          data.add(PoseData3D(PoseFunction3D.getPoseDataFromList(event['data'][i])));
        }
        return data;
      case 'noData':
        break;
      case 'done':
        break;
      case 'error':
      print(event['code']);
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
