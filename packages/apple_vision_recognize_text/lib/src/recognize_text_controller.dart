import 'dart:async';

import 'package:apple_vision_recognize_text/apple_vision_recognize_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';

/// The [AppleVisionRecognizeTextController] holds all the logic of this plugin,
/// where as the [AppleVisionObject] class is the frontend of this plugin.
class AppleVisionRecognizeTextController {
  static const MethodChannel _methodChannel = MethodChannel('apple_vision/recognize_text');
  
  AppleVisionRecognizeTextController({
    this.numberOfCandidates = 1,
    //this.languages = const []
  });

  int numberOfCandidates;
  //final List<String> languages;

  /// Process the image using apple vision and return the requested information or null value
  /// 
  /// [image] as Uint8List is the image that needs to be processed
  /// this needs to be in an image format raw will not work.
  /// 
  /// [imageSize] as Size is the size of the image that is being processed
  /// 
  /// [orientation] The orientation of the image
  /// 
  /// [recognitionLevel] A value that determines whether the request prioritizes accuracy or speed in text recognition.
  Future<List<RecognizedText>?> processImage({
    required Uint8List image,
    required Size imageSize,
    ImageOrientation orientation = ImageOrientation.down,
    RecognitionLevel recognitionLevel = RecognitionLevel.accurate,
  }) async{
    try {
      final data = await _methodChannel.invokeMapMethod<String, dynamic>(  
        'process',
        {'image':image,
          'width': imageSize.width,
          'height':imageSize.height,
          'candidates': numberOfCandidates,
          'orientation': orientation.name,
          'recognitionLevel': recognitionLevel.name,
          //'languages': languages
        },
      );
      return _convertData(data);
    } catch (e) {
      debugPrint('$e');
    }

    return null;
  }

  /// Objectles a returning event from the platform side
  List<RecognizedText>? _convertData(Map? event) {
    if(event == null) return null;
    final name = event['name'];

    switch (name) {
      case 'recognizeText':
        List<RecognizedText> data = RecognizeTextFunctions.getObjectDataFromList(
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

class RecognizedText{
  RecognizedText(this.boundingBox,this.listText);

  final Rect boundingBox;
  final List<String> listText;
}

/// A class that converts the information from apple vision to dart
class RecognizeTextFunctions{
  /// Convert rect data from apple vision to usable dart data
  static List<RecognizedText> getObjectDataFromList(List<Object?> object){
    List<RecognizedText> data = [];
    for(int i = 0; i < object.length; i++){
      Map map = object[i] as Map;
      List<String> text = [];
      for(int j = 0; j < map['text'].length;j++){
        text.add(map["text"][j]);
      }
      data.add(
        RecognizedText(
          Rect.fromCenter(center: Offset(map['origin']['x'],map['origin']['y']),width: map['width'],height: map['height']),
          text
        )
      );
    }

    return data;
  }
}