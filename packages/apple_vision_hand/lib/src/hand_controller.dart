import 'dart:async';

import 'package:apple_vision_hand/src/hand_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_hand/apple_vision_hand.dart';

/// The [AppleVisionHandController] holds all the logic of this plugin,
/// where as the [AppleVisionHand] class is the frontend of this plugin.
class AppleVisionHandController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/hand');

  Future<HandData?> processImage(Uint8List image, Size imageSize) async{
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

  /// Handles a returning event from the platform side
  HandData? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];
    switch (name) {
      case 'hand':
        HandData data = HandData(HandFunctions().getHandDataFromList(event['data']),Size(event['imageSize']['width'],event['imageSize']['height']));
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
