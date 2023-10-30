import 'package:apple_vision_animal_pose/apple_vision_animal_pose.dart';
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
      home: const VisionAnimalPose(),
    );
  }
}


class VisionAnimalPose extends StatefulWidget {
  const VisionAnimalPose({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionAnimalPose createState() => _VisionAnimalPose();
}

class _VisionAnimalPose extends State<VisionAnimalPose>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionAnimalPoseController visionController = AppleVisionAnimalPoseController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<AnimalPoseData>? poseData;
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
    Map<AnimalJoint,Color> colors = {
      AnimalJoint.rightBackElbow: Colors.orange,
      AnimalJoint.rightBackKnee: Colors.orange,
      AnimalJoint.rightBackPaw: Colors.orange,

      //AnimalJoint.rightFronElbow: Colors.purple,
      AnimalJoint.rightFrontKnee: Colors.purple,
      AnimalJoint.rightFrontPaw: Colors.purple,

      AnimalJoint.nose: Colors.pink,
      AnimalJoint.neck: Colors.pink,

      AnimalJoint.leftFrontPaw: Colors.indigo,
      AnimalJoint.leftFrontKnee: Colors.indigo,
      //AnimalJoint.leftFronElbow: Colors.indigo,

      AnimalJoint.leftBackElbow: Colors.grey,
      AnimalJoint.leftBackKnee: Colors.grey,
      AnimalJoint.leftBackPaw: Colors.grey,

      AnimalJoint.tailTop: Colors.yellow,
      AnimalJoint.tailMiddle: Colors.yellow,
      AnimalJoint.tailBottom: Colors.yellow,

      AnimalJoint.leftEye: Colors.cyanAccent,
      AnimalJoint.leftEarTop: Colors.cyanAccent,
      AnimalJoint.leftEarBottom: Colors.cyanAccent,
      AnimalJoint.rightEarTop: Colors.blue,
      AnimalJoint.rightEarBottom: Colors.blue,
      AnimalJoint.rightEye: Colors.blue,
    };
    List<Widget> widgets = [];
    for(int j = 0; j < poseData!.length;j++){
      for(int i = 0; i < poseData![j].poses.length; i++){
        if(poseData![j].poses[i].confidence > 0.5){
          widgets.add(
            Positioned(
              top: poseData![j].poses[i].location.y,
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