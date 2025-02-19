import 'package:apple_vision_pose/apple_vision_pose.dart';
import 'package:flutter/material.dart';
import '../camera/camera_insert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'camera/input_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VisionPose(),
    );
  }
}


class VisionPose extends StatefulWidget {
  const VisionPose({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionPose createState() => _VisionPose();
}

class _VisionPose extends State<VisionPose>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionPoseController visionController = AppleVisionPoseController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<PoseData>? poseData;
  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    camera.setupCameras().then((value){
      setState(() {
        loading = false;
      });
      camera.startLiveFeed((InputImage i){
        if(i.metadata?.size != null){
          imageSize = i.metadata!.size;
        }
        if(mounted) {
          Uint8List? image = i.bytes;
          visionController.processImage(image!, i.metadata!.size).then((data){
            poseData = data;
            setState(() {
              
            });
          });
        }
      });
    });
    super.initState();
  }
  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Stack(
      children:<Widget>[
        SizedBox(
          width: imageSize.width, 
          height: imageSize.height, 
          child: loading?Container():CameraSetup(camera: camera, size: imageSize)
      ),
      ]+showPoints()
    );
  }

  List<Widget> showPoints(){
    if(poseData == null || poseData!.isEmpty) return[];
    Map<Joint,Color> colors = {
      Joint.rightFoot: Colors.orange,
      Joint.rightLeg: Colors.orange,
      Joint.rightUpLeg: Colors.orange,

      Joint.rightHand: Colors.purple,
      Joint.rightForearm: Colors.purple,

      Joint.nose: Colors.purple,

      Joint.neck: Colors.pink,
      Joint.rightShoulder: Colors.pink,
      Joint.leftShoulder: Colors.pink,

      Joint.leftForearm: Colors.indigo,
      Joint.leftHand: Colors.indigo,

      Joint.leftUpLeg: Colors.grey,
      Joint.leftLeg: Colors.grey,
      Joint.leftFoot: Colors.grey,

      Joint.root: Colors.yellow,

      Joint.leftEye: Colors.cyanAccent,
      Joint.leftEar: Colors.cyanAccent,
      Joint.rightEar: Colors.cyanAccent,
      Joint.rightEye: Colors.cyanAccent,
      Joint.head: Colors.cyanAccent
    };
    List<Widget> widgets = [];
    for(int j = 0; j < poseData!.length;j++){
      for(int i = 0; i < poseData![j].poses.length; i++){
        if(poseData![j].poses[i].confidence > 0.3){
          widgets.add(
            Positioned(
              top: imageSize.height-poseData![j].poses[i].location.y,
              left: poseData![j].poses[i].location.x,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[poseData![j].poses[i].joint],
                  borderRadius: BorderRadius.circular(5)
                ),
              )
            )
          );
        }
      }
    }
    return widgets;
  }
}