/// The coordinate points of the face
/// 
/// [x] X location
/// [y] Y location
class FacePoint{
  FacePoint(this.x,this.y, this.z);
  final double x;
  final double y;
  final double z;
}

/// A class that has all the information on the face detected
/// 
/// [mesh] The marks found in the image.
/// [confidence] The confidence of the information returned
class FaceMesh{
  FaceMesh({
    required this.mesh,
    this.confidence
  });
  final List<FacePoint> mesh;
  final double? confidence;

  factory FaceMesh.fromJson(Map json){
    List<FacePoint> points = [];
    for(int i = 0; i < json['mesh'].length-1;i+=3){
      points.add(FacePoint(json['mesh'][i], json['mesh'][i+1], json['mesh'][i+2]));
    }
    return FaceMesh(
      mesh: points,
      confidence: json['confidence']
    );
  }
}