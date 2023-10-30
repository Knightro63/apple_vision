/// The Joint of the body received from apple vision
enum AnimalJoint {
  rightBackElbow,
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
  AnimalPoseData(this.poses);
  List<AnimalPose> poses;
}

/// A class that converts the information from apple vision to dart
class AnimalPoseFunctions {
  /// Convert pose data from apple vision to usable dart data
  static List<AnimalPose> getAniamlPoseDataFromList(Map object) {
    List<AnimalPose> data = [];
    for (String temp in object.keys) {
      data.add(AnimalPose(getAnimalJointFromString(temp)!,
          AnimalPosePoint(object[temp]['x'], object[temp]['y']), object[temp]['confidence']));
    }

    return data;
  }

  /// Get the joint information for a string format and convert to an enum Joint
  static AnimalJoint? getAnimalJointFromString(String joint) {
    String other = joint.replaceAll('_', '');
    for (int i = 0; i < AnimalJoint.values.length; i++) {
      if ('animaljoint${AnimalJoint.values[i].name.toLowerCase()}' == other.toLowerCase()) {
        return AnimalJoint.values[i];
      }
      else if('animaljointheck' == other.toLowerCase()){
        return AnimalJoint.neck;
      }
    }
    return null;
  }
}
