import 'package:flutter/material.dart';

/// The landmarks of the face received from apple vision
enum LandMark{
  faceContour,
  outerLips,
  innerLips,
  leftEye,
  rightEye,
  leftPupil,
  rightPupil,
  leftEyebrow,
  rightEyebrow
}

/// The coordinate points of the face
/// 
/// [x] X location
/// [y] Y location
class FacePoint{
  FacePoint(this.x,this.y);
  final double x;
  final double y;
}

/// A class that gives The type of landmark and the location of the landmark or marks
/// 
/// [landmark] the spot on the face
/// [location] where the position of the spot in x and y coords
class Face{
  Face(this.landmark,this.location);
  final LandMark landmark;
  final List<FacePoint> location;
}

/// A class that has all the information on the face detected
/// 
/// [marks] The marks found in the image.
/// [imageSize] The size of the image sent.
/// [yaw] The yaw of the face. This is the head turned to the side.
/// [roll] The roll of the face. This is head tilted to the side.
/// [pitch] The pitch of the face. This is the head tilting backwards.
/// [quality] The quality of the information returned
class FaceData{
  FaceData({
    required this.marks,
    required this.imageSize,
    required this. yaw,
    required this.roll,
    this.pitch,
    this.quality
  });
  final List<Face> marks;
  final Size imageSize;
  final double yaw;
  final double roll;
  final double? pitch;
  final double? quality;

  @override
  String toString() {
    return {
      'yaw': yaw,
      'roll': roll,
      'pitch': pitch,
      'quality': quality,
      'width': imageSize.width,
      'height':imageSize.height
    }.toString();
  }
}

/// A class that converts the information from apple vision to dart
class FaceFunctions{

  /// Convert face data from apple vision to usable dart data
  static List<Face> getFaceDataFromList(List<Object?> object){
    List<Face> data = [];
    for(int i = 0; i < object.length; i++){
      Map map = (object[i] as Map);
      String temp = map.keys.first;
      List<FacePoint> points = [];
      for(int j = 0; j < map[temp].length;j++){
        points.add(FacePoint(map[temp][j]['x'], map[temp][j]['y']));
      }
      data.add(
        Face(
          getJointFromString(temp)!, 
          points
        )
      );
    }

    return data;
  }

  /// Get the joint information for a string format and convert to an enum Landmark
  static LandMark? getJointFromString(String joint){
    for(int i = 0; i < LandMark.values.length;i++){
      if(LandMark.values[i].name == joint){
        return LandMark.values[i];
      }
    }

    return LandMark.faceContour;
  }
}