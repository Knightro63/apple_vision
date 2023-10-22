import 'package:flutter/material.dart';

/// All the data received from apple vision
/// 
/// [object] is the location and size of the object
/// 
/// [label] the label of the object
/// [confidence] confidence that object is that object as a double between 0-1
class ObjectData{
  ObjectData({
    required this.object,
    required this.label,
    required this.confidence
  });
  Rect object;
  final double confidence;
  final String label;
}

/// A class that converts the information from apple vision to dart
class ObjectFunctions{
  /// Convert rect data from apple vision to usable dart data
  static ObjectData getObjectDataFromList(Object? object){
    Map map = object as Map;
    ObjectData data = ObjectData(
      confidence: map['confidence'],
      label: map['label'],
      object: Rect.fromCenter(center: Offset(map['origin']['x'],map['origin']['y']),width: map['width'],height: map['height'])
    );

    return data;
  }
}