import 'package:flutter/material.dart';

/// The Joint of the body received from apple vision
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

/// The coordinate points of the body
/// 
/// [x] X location
/// [y] Y location
class PosePoint {
  PosePoint(this.x, this.y);
  final double x;
  final double y;
}

/// A class that gives the type of joint and the location of the joint and the confidence that it is that joint
/// 
/// [joint] the joint found
/// [location] where the position of the joint in x and y coords
/// [confidence] the percentage that it is that joint
class Pose {
  Pose(this.joint, this.location, this.confidence);
  final Joint joint;
  final PosePoint location;
  final double confidence;
}

/// A class that has all the information on the body detected
/// 
/// [poses] The joint information gathered.
/// [imageSize] The size of the image sent.
class PoseData {
  PoseData(this.poses, this.imageSize);
  List<Pose> poses;
  Size imageSize;
}

/// A class that converts the information from apple vision to dart
class PoseFunctions {
  /// Convert pose data from apple vision to usable dart data
  static List<Pose> getPoseDataFromList(List<Object?> object) {
    List<Pose> data = [];
    for (int i = 0; i < object.length; i++) {
      Map map = (object[i] as Map);
      String temp = map.keys.first;
      data.add(Pose(getJointFromString(temp)!,
          PosePoint(map[temp]['x'], map[temp]['y']), map[temp]['confidence']));
    }

    return data;
  }

  /// Get the joint information for a string format and convert to an enum Joint
  static Joint? getJointFromString(String joint) {
    for (int i = 0; i < Joint.values.length; i++) {
      String other =
          joint.replaceAll("joint", '').replaceAll('1', '').replaceAll('_', '');
      if (Joint.values[i].name.toLowerCase() == other.toLowerCase()) {
        return Joint.values[i];
      }
    }
    return null;
  }
}
