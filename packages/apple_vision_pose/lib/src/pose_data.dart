import 'package:flutter/material.dart';

enum Joint {
  rightFoot, // Right Ankle
  rightLeg, // Right Knee
  rightUpLeg, // Right Hip
  rightHand, // Right Wrist
  rightForearm, // Right Elbow
  rightShoulder,
  rightEar,
  rightEye,
  nose,
  head,
  neck,
  leftEye,
  leftEar,
  leftShoulder,
  leftForearm, // Left Elbow
  leftHand, // Left Wrist
  leftUpLeg, // Left Hip
  leftLeg, // Left Knee
  leftFoot, // Left Ankle
  root,
}

class PosePoint {
  PosePoint(this.x, this.y);
  double x;
  double y;
}

class Pose {
  Pose(this.joint, this.location, this.confidence);
  Joint joint;
  PosePoint location;
  double confidence;
}

class PoseData {
  PoseData(this.poses, this.imageSize);
  List<Pose> poses;
  Size imageSize;
}

class PoseFunctions {
  List<Pose> getPoseDataFromList(List<Object?> object) {
    List<Pose> data = [];
    for (int i = 0; i < object.length; i++) {
      Map map = (object[i] as Map);
      String temp = map.keys.first;
      data.add(Pose(getJointFromString(temp)!,
          PosePoint(map[temp]['x'], map[temp]['y']), map[temp]['confidence']));
    }

    return data;
  }

  Joint? getJointFromString(String joint) {
    for (int i = 0; i < Joint.values.length; i++) {
      String other =
          joint.replaceAll("joint", '').replaceAll('1', '').replaceAll('_', '');
      if (Joint.values[i].name.toLowerCase() == other.toLowerCase()) {
        return Joint.values[i];
      }
    }
    print(joint);
    return null;
  }
}
