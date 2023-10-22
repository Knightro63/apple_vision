import 'package:flutter/material.dart';

/// The joints of the hand received from apple vision
enum FingerJoint{
  thumbIP,
  thumbMP,
  thumbCMC,
  thumbTip,
  
  indexDIP,
  indexMCP,
  indexPIP,
  indexTip,
  
  middleDIP,
  middleMCP,
  middlePIP,
  middleTip,
  
  ringDIP,
  ringMCP,
  ringPIP,
  ringTip,
  
  littleDIP,
  littleMCP,
  littlePIP,
  littleTip
}

/// Other joint types of the hand received from apple vision
enum JointOther{
  vnhlktip,
  vnhlktmp,
  vnhlktcmc,
  vnhlkttip,
  vnhlkidip,
  vnhlkimcp,
  vnhlkipip,
  vnhlkitip,
  vnhlkmdip,
  vnhlkmmcp,
  vnhlkmpip,
  vnhlkmtip,
  vnhlkrdip,
  vnhlkrmcp,
  vnhlkrpip,
  vnhlkrtip,
  vnhlkpdip,
  vnhlkpmcp,
  vnhlkppip,
  vnhlkptip,
}

/// The coordinate points of the hand
/// 
/// [x] X location
/// [y] Y location
class HandPoint{
  HandPoint(this.x,this.y);
  final double x;
  final double y;
}

/// A class that gives the type of joint and the location of the joint and the confidence that it is that joint
/// 
/// [joint] the joint found
/// [location] where the position of the joint in x and y coords
/// [confidence] the percentage that it is that joint
class Hand{
  Hand(this.joint,this.location,this.confidence);
  final FingerJoint joint;
  final HandPoint location;
  final double confidence;
}

/// A class that has all the information on the hand detected
/// 
/// [poses] The joint information gathered.
/// [imageSize] The size of the image sent.
class HandData{
  HandData(this.poses,this.imageSize);
  final List<Hand> poses;
  final Size imageSize;
}

/// A class that converts the information from apple vision to dart
class HandFunctions{

  /// Convert hand data from apple vision to usable dart data
  static List<Hand> getHandDataFromList(List<Object?> object){
    List<Hand> data = [];
    for(int i = 0; i < object.length; i++){
      Map map = (object[i] as Map);
      String temp = map.keys.first;
      data.add(
        Hand(getJointFromString(temp)!, HandPoint(map[temp]['x'], map[temp]['y']),map[temp]['confidence'])
      );
    }

    return data;
  }

  /// Get the joint information for a string format and convert to an enum FingerJoint
  static FingerJoint? getJointFromString(String joint){
    for(int i = 0; i < FingerJoint.values.length;i++){
      if(JointOther.values[i].name.toLowerCase() == joint.toLowerCase()){
        return FingerJoint.values[i];
      }
    }

    return FingerJoint.indexDIP;
  }
}