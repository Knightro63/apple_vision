import 'package:flutter/material.dart';

enum Joint{
  rightFoot,
  rightAnkle,
  rightLeg,
  rightKnee,
  rightUpLeg,
  rightHip,
  rightHand,
  rightWrist,
  rightForearm,
  rightElbow,
  rightShoulder,
  rightEar,
  rightEye,
  nose,
  head,
  neck,
  leftEye,
  leftEar,
  leftShoulder,
  leftElbow,
  leftForearm,
  leftWrist,
  leftHand,
  leftHip,
  leftUpLeg,
  leftKnee,
  leftLeg,
  leftAnkle,
  leftFoot,
  root
}

class Point{
  Point(this.x,this.y);
  double x;
  double y;
}

class Pose{
  Pose(this.joint,this.location,this.confidence);
  Joint joint;
  Point location;
  double confidence;
}

class PoseData{
  PoseData(this.poses,this.imageSize);
  List<Pose> poses;
  Size imageSize;
}

class PoseFunctions{
  List<Pose> getPoseDataFromList(List<Object?> object){
    List<Pose> data = [];
    for(int i = 0; i < object.length; i++){
      Map map = (object[i] as Map);
      String temp = map.keys.first;
      data.add(
        Pose(getJointFromString(temp)!, Point(map[temp]['x'], map[temp]['y']),map[temp]['confidence'])
      );
    }

    return data;
  }
  Joint? getJointFromString(String joint){
    for(int i = 0; i < Joint.values.length;i++){
      String other = joint.replaceAll("joint", '').replaceAll('1', '').replaceAll('_', '');
      if(Joint.values[i].name.toLowerCase() == other.toLowerCase()){
        return Joint.values[i];
      }
    }
    print(joint);
    return null;
  }
}