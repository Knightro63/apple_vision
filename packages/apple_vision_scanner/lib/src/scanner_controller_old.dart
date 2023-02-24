import 'dart:async';
import 'package:apple_vision_commons/apple_vision_commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_scanner/apple_vision_scanner.dart';

/// The [AppleVisionPoseController] holds all the logic of this plugin,
/// where as the [AppleVisionPose] class is the frontend of this plugin.
class AppleVisionPoseController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/scanner');

  Future<PoseData?> process(Uint8List image, Size imageSize) async{
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
  PoseData? _convertData(Map? event) {
    //event = ["name": "barcode", "data" : ["payload": barcode.payloadStringValue, "symbology": barcodeType]]

    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'barcode':
        PoseData data = PoseData(PoseFunctions().getPoseDataFromList(event['data']),Size(event['imageSize']['width'],event['imageSize']['height']));
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
