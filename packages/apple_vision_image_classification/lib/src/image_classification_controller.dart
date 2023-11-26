import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';

/// The [AppleVisionImageClassificationController] holds all the logic of this plugin,
/// where as the [AppleVisionObject] class is the frontend of this plugin.
class AppleVisionImageClassificationController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/image_classification');

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  Future<List<Label>?> processImage(Uint8List image, Size imageSize, [double confidence = 0.75,ImageOrientation orientation = ImageOrientation.downMirrored]) async{
    try {
      final data = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':image,
          'width': imageSize.width,
          'height':imageSize.height,
          'confidence': confidence,
          'orientation': orientation.name
        }
      );
      return _convertData(data);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }

  /// Objectles a returning event from the platform side
  List<Label>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'imageClassify':
        List<Label> data =
          ObjectFunctions.getObjectDataFromList(
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

/// A class that has all the label data in it
class Label{
  Label({
    required this.label,
    required this.confidence
  });

  final double confidence;
  final String label;
}

/// A class that converts the information from apple vision to dart
class ObjectFunctions{
  /// Convert rect data from apple vision to usable dart data
  static List<Label> getObjectDataFromList(List<Object?> object){
    List<Label> data = [];
    for(int i = 0; i < object.length; i++){
      Map map = object[i] as Map;
      data.add(
        Label(
          label: map['label'],
          confidence: map['confidence']
        )
      );
    }

    return data;
  }
}
