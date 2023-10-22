import 'package:flutter/material.dart';

/// The Joint of the body received from apple vision
enum AnimalJoint {
  rightBackElbow,
  rightFronElbow,
  rightBackKnee,
  rightFrontKnee,
  rightBackPaw,
  rightFrontPaw,

  rightEarTop,
  rightEarMiddle,
  rightEarBottom,
  rightEye,
  nose,
  neck,
  leftEye,
  leftEarTop,
  leftEarMiddle,
  leftEarBottom,

  leftBackElbow,
  leftFronElbow,
  leftBackKnee,
  leftFrontKnee,
  leftBackPaw,
  leftFrontPaw,

  tailTop,
  tailMiddle,
  tailBottom
}

/// The coordinate points of the body
/// 
/// [x] X location
/// [y] Y location
class AnimalPosePoint {
  AnimalPosePoint(this.x, this.y);
  final double x;
  final double y;
}

/// A class that gives the type of joint and the location of the joint and the confidence that it is that joint
/// 
/// [joint] the joint found
/// [location] where the position of the joint in x and y coords
/// [confidence] the percentage that it is that joint
class AnimalPose {
  AnimalPose(this.joint, this.location, this.confidence);
  final AnimalJoint joint;
  final AnimalPosePoint location;
  final double confidence;
}

/// A class that has all the information on the body detected
/// 
/// [poses] The joint information gathered.
/// [imageSize] The size of the image sent.
class AnimalPoseData {
  AnimalPoseData(this.poses, this.imageSize);
  List<AnimalPose> poses;
  Size imageSize;
}

/// A class that converts the information from apple vision to dart
class AnimalPoseFunctions {
  /// Convert pose data from apple vision to usable dart data
  static List<AnimalPose> getAniamlPoseDataFromList(List<Object?> object) {
    List<AnimalPose> data = [];
    for (int i = 0; i < object.length; i++) {
      Map map = (object[i] as Map);
      String temp = map.keys.first;
      data.add(AnimalPose(getAnimalJointFromString(temp)!,
          AnimalPosePoint(map[temp]['x'], map[temp]['y']), map[temp]['confidence']));
    }

    return data;
  }

  /// Get the joint information for a string format and convert to an enum Joint
  static AnimalJoint? getAnimalJointFromString(String joint) {
    for (int i = 0; i < AnimalJoint.values.length; i++) {
      String other =
          joint.replaceAll("joint", '').replaceAll('1', '').replaceAll('_', '');
      if (AnimalJoint.values[i].name.toLowerCase() == other.toLowerCase()) {
        return AnimalJoint.values[i];
      }
    }
    return null;
  }
}
