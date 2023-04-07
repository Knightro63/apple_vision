import 'package:flutter/material.dart';

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

class FacePoint{
  FacePoint(this.x,this.y);
  double x;
  double y;
}

class Face{
  Face(this.landmark,this.location);
  LandMark landmark;
  List<FacePoint> location;
}

class FaceData{
  FaceData({
    required this.marks,
    required this.imageSize,
    required this. yaw,
    required this.roll,
    this.pitch,
    this.quality
  });
  List<Face> marks;
  Size imageSize;
  double yaw;
  double roll;
  double? pitch;
  double? quality;
}

class FaceFunctions{
  List<Face> getFaceDataFromList(List<Object?> object){
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
  LandMark? getJointFromString(String joint){
    for(int i = 0; i < LandMark.values.length;i++){
      if(LandMark.values[i].name == joint){
        return LandMark.values[i];
      }
    }

    return LandMark.faceContour;
  }
}