import 'package:flutter/material.dart';

enum Joint{
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
  VNHLKTIP,
  VNHLKTMP,
  VNHLKTCMC,
  VNHLKTTIP,
  VNHLKIDIP,
  VNHLKIMCP,
  VNHLKIPIP,
  VNHLKITIP,
  VNHLKMDIP,
  VNHLKMMCP,
  VNHLKMPIP,
  VNHLKMTIP,
  VNHLKRDIP,
  VNHLKRMCP,
  VNHLKRPIP,
  VNHLKRTIP,
  VNHLKPDIP,
  VNHLKPMCP,
  VNHLKPPIP,
  VNHLKPTIP,
}



class Point{
  Point(this.x,this.y);
  double x;
  double y;
}

class Hand{
  Hand(this.joint,this.location,this.confidence);
  Joint joint;
  Point location;
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
        Hand(getJointFromString(temp)!, Point(map[temp]['x'], map[temp]['y']),map[temp]['confidence'])
      );
    }

    return data;
  }
  Joint? getJointFromString(String joint){
    for(int i = 0; i < Joint.values.length;i++){
      if(JointOther.values[i].name.toLowerCase() == joint.toLowerCase()){
        return Joint.values[i];
      }
    }

    return Joint.indexDIP;
  }
}