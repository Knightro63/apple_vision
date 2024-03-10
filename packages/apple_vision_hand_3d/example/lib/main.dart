import 'package:apple_vision_hand_3d/apple_vision_hand_3d.dart';
import 'package:apple_vision_commons/apple_vision_commons.dart';
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
      home: const VisionHand(),
    );
  }
}

class VisionHand extends StatefulWidget {
  const VisionHand({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionHand createState() => _VisionHand();
}

class _VisionHand extends State<VisionHand>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  AppleVisionHand3DController visionController = AppleVisionHand3DController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<HandMesh>? handData;
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
          visionController.processImage(image!, imageSize, ImageOrientation.up).then((data){
            handData = data;
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
    if(handData == null || handData!.isEmpty) return[];
    List<Widget> widgets = [];
    Map<FingerJoint3D,Color> colors = {
      FingerJoint3D.thumbCMC: Colors.amber,
      FingerJoint3D.thumbIP: Colors.amber,
      FingerJoint3D.thumbMCP: Colors.amber,
      FingerJoint3D.thumbTip: Colors.amber,

      FingerJoint3D.indexDIP: Colors.green,
      FingerJoint3D.indexMCP: Colors.green,
      FingerJoint3D.indexPIP: Colors.green,
      FingerJoint3D.indexTip: Colors.green,

      FingerJoint3D.middleDIP: Colors.purple,
      FingerJoint3D.middleMCP: Colors.purple,
      FingerJoint3D.middlePIP: Colors.purple,
      FingerJoint3D.middleTip: Colors.purple,

      FingerJoint3D.ringDIP: Colors.pink,
      FingerJoint3D.ringMCP: Colors.pink,
      FingerJoint3D.ringPIP: Colors.pink,
      FingerJoint3D.ringTip: Colors.pink,

      FingerJoint3D.littleDIP: Colors.cyanAccent,
      FingerJoint3D.littleMCP: Colors.cyanAccent,
      FingerJoint3D.littlePIP: Colors.cyanAccent,
      FingerJoint3D.littleTip: Colors.cyanAccent,

      FingerJoint3D.wrist: Colors.black
    };
    for(int j = 0; j < handData!.length; j++){
      //print(handData![j].poses[0].location.y);
      for(int i = 0; i < handData![j].poses.length; i++){
        HandPoint3D points = handData![j].poses[i].location;
        widgets.add(
          Positioned(
            left: points.x * imageSize.width/2.56 + handData![0].image.origin.x,
            bottom: imageSize.height/2 - points.y * imageSize.width/2.56 + handData![0].image.origin.y+120,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[handData![j].poses[i].joint],
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
      height:deviceHeight,
      color: Theme.of(context).canvasColor,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Colors.blue)
    );
  }
}
