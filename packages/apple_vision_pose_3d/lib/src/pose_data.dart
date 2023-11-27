/// The Joint of the body received from apple vision
enum Joint3D {
  rightAnkle, // Right Ankle
  rightKnee, // Right Knee
  rightHip, // Right Hip
  rightWrist, // Right Wrist
  rightElbow, // Right Elbow
  rightShoulder,
  leftShoulder,
  leftElbow, // Left Elbow
  leftWrist, // Left Wrist
  leftHip, // Left Hip
  leftKnee, // Left Knee
  leftAnkle, // Left Ankle
  centerHead,
  centerShoulder,
  spine,
  topHead,
  root,
}

/// The coordinate points of the body
/// 
/// [x] X location relative to the root position
/// [y] Y location relative to the root position
/// [z] Z location relative to the root position
/// [pitch] Pitch location
/// [yaw] Yaw location
/// [roll] Raw location
class PosePoint3D {
  PosePoint3D(this.x, this.y, this.z, this.pitch, this.yaw, this.roll);
  final double x;
  final double y;
  final double z;
  final double pitch;
  final double yaw;
  final double roll;
}

/// The coordinate points of the body
/// 
/// [x] X location
/// [y] Y location
class PosePoint2D {
  PosePoint2D(this.x, this.y);
  final double x;
  final double y;
}

/// A class that gives the type of joint and the location of the joint and the confidence that it is that joint
/// 
/// [joint] the joint found
/// [location] where the position of the joint in x and y coords
class Pose3D {
  Pose3D(this.joint, this.height, this.location, this.location3D);
  final Joint3D joint;
  final PosePoint3D location3D;
  final PosePoint2D location;
  final double height;
}

/// A class that has all the information on the body detected
/// 
/// [poses] The joint information gathered.
class PoseData3D {
  PoseData3D(this.poses);
  List<Pose3D> poses;
}

/// A class that converts the information from apple vision to dart
class PoseFunction3D {
  /// Convert pose data from apple vision to usable dart data
  static List<Pose3D> getPoseDataFromList(List<Object?> object) {
    List<Pose3D> data = [];
    for (int i = 0; i < object.length;i++) {
      Map map = object[i] as Map;
      data.add(
        Pose3D(
          getJointFromString(map['description'])!,
          map['height'],
          PosePoint2D(map['x'], map['y']),
          PosePoint3D(map['X'], map['Y'], map['Z'], map['pitch'], map['yaw'],map['roll'])
        )
      );
    }
    return data;
  }

  /// Get the joint information for a string format and convert to an enum Joint
  static Joint3D? getJointFromString(String joint) {
    for (int i = 0; i < Joint3D.values.length; i++) {
      String other = joint.replaceAll("human_", '').replaceAll('_3D', '').replaceAll('_', '');
      if (Joint3D.values[i].name.toLowerCase() == other.toLowerCase()) {
        return Joint3D.values[i];
      }
    }
    return null;
  }
}
