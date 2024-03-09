import 'dart:typed_data';

import 'package:flutter/material.dart';

/// The joints of the hand received from apple vision
enum FingerJoint3D{
  wrist,
  thumbCMC,
  thumbMCP,
  thumbIP,
  thumbTip,

  indexMCP,
  indexPIP,
  indexDIP,
  indexTip,
  
  middleMCP,
  middlePIP,
  middleDIP,
  middleTip,
  
  ringMCP,
  ringPIP,
  ringDIP,
  ringTip,
  
  littleMCP,
  littlePIP,
  littleDIP,
  littleTip
}

/// The coordinate points of the hand
/// 
/// [x] X location
/// [y] Y location
class HandPoint3D{
  HandPoint3D(this.x,this.y,this.z);
  final double x;
  final double y;
  final double z;
}

/// A class that gives the type of joint and the location of the joint and the confidence that it is that joint
/// 
/// [joint] the joint found
/// [location] where the position of the joint in x and y coords
/// [confidence] the percentage that it is that joint
class Hand3D{
  Hand3D(this.joint,this.location);
  final FingerJoint3D joint;
  final HandPoint3D location;
}

class HandImage{
  HandImage({
    required this.croppedImage,
    required this.size,
    required this.origin,
  });

  final Size size;
  final Uint8List croppedImage;
  final HandPoint3D origin; 
}

/// A class that has all the information on the hand detected
/// 
/// [poses] The joint information gathered.
/// [imageSize] The size of the image sent.
class HandMesh{
  HandMesh({
    required this.poses,
    required this.image,
    this.confidence
  });
  final List<Hand3D> poses;
  final HandImage image;
  final double? confidence;

  factory HandMesh.fromJson(Map json){
    List<Hand3D> points = [];
    List<double> raw = [];
    print(json['mesh']);
    for(int i = 0; i < json['mesh'].length-1;i+=3){
      points.add(
        Hand3D(
          FingerJoint3D.values[i],
          HandPoint3D(json['mesh'][i], json['mesh'][i+1], json['mesh'][i+2])
        )
      );
      raw.addAll([json['mesh'][i], json['mesh'][i+1], json['mesh'][i+2]]);
    }
    return HandMesh(
      poses: points,
      confidence: json['confidence'],
      image: HandImage(
        croppedImage: json['croppedImage'],
        origin: HandPoint3D(json['origin']["x"],json['origin']["y"],0),
        size: Size(json['imageSize']["width"],json['imageSize']["height"])
      ),
    );
  }
}