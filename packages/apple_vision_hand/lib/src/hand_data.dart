import 'package:flutter/material.dart';

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



class HandPoint{
  HandPoint(this.x,this.y);
  double x;
  double y;
}

class Hand{
  Hand(this.joint,this.location,this.confidence);
  FingerJoint joint;
  HandPoint location;
  double confidence;
}

class HandData{
  HandData(this.poses,this.imageSize);
  List<Hand> poses;
  Size imageSize;
}

class HandFunctions{
  List<Hand> getHandDataFromList(List<Object?> object){
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
  FingerJoint? getJointFromString(String joint){
    for(int i = 0; i < FingerJoint.values.length;i++){
      if(JointOther.values[i].name.toLowerCase() == joint.toLowerCase()){
        return FingerJoint.values[i];
      }
    }

    return FingerJoint.indexDIP;
  }
}