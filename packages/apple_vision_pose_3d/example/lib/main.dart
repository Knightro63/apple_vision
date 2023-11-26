import 'package:apple_vision_pose_3d/apple_vision_pose_3d.dart';
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
  late AppleVisionPose3DController visionController = AppleVisionPose3DController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<PoseData3D>? poseData;
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
    Map<Joint3D,Color> colors = {
      Joint3D.rightAnkle: Colors.orange,
      Joint3D.rightKnee: Colors.orange,
      Joint3D.rightHip: Colors.orange,

      Joint3D.rightWrist: Colors.purple,
      Joint3D.rightElbow: Colors.purple,

      Joint3D.rightShoulder: Colors.pink,
      Joint3D.leftShoulder: Colors.pink,

      Joint3D.leftElbow: Colors.indigo,
      Joint3D.leftWrist: Colors.indigo,

      Joint3D.leftHip: Colors.grey,
      Joint3D.leftKnee: Colors.grey,
      Joint3D.leftAnkle: Colors.grey,

      Joint3D.root: Colors.yellow,
      Joint3D.centerShoulder: Colors.yellow,
      Joint3D.spine: Colors.yellow,

      Joint3D.centerHead: Colors.cyanAccent,
      Joint3D.topHead: Colors.cyanAccent
    };
    List<Widget> widgets = [];
    for(int j = 0; j < poseData!.length;j++){
      for(int i = 0; i < poseData![j].poses.length; i++){
        widgets.add(
          Positioned(
            top: poseData![j].poses[i].location.y * imageSize.height,
            left: poseData![j].poses[i].location.x * imageSize.width,
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
    return widgets;
  }

  Widget loadingWidget(){
    return Container(
      width: deviceWidth,
      height: deviceHeight,
      color: Theme.of(context).canvasColor,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Colors.blue)
    );
  }
}