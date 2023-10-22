import 'package:apple_vision_hand/apple_vision_hand.dart';
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
  AppleVisionHandController visionController = AppleVisionHandController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<HandData>? handData;
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
          visionController.processImage(image!, imageSize).then((data){
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
    Map<FingerJoint,Color> colors = {
      FingerJoint.thumbCMC: Colors.amber,
      FingerJoint.thumbIP: Colors.amber,
      FingerJoint.thumbMP: Colors.amber,
      FingerJoint.thumbTip: Colors.amber,

      FingerJoint.indexDIP: Colors.green,
      FingerJoint.indexMCP: Colors.green,
      FingerJoint.indexPIP: Colors.green,
      FingerJoint.indexTip: Colors.green,

      FingerJoint.middleDIP: Colors.purple,
      FingerJoint.middleMCP: Colors.purple,
      FingerJoint.middlePIP: Colors.purple,
      FingerJoint.middleTip: Colors.purple,

      FingerJoint.ringDIP: Colors.pink,
      FingerJoint.ringMCP: Colors.pink,
      FingerJoint.ringPIP: Colors.pink,
      FingerJoint.ringTip: Colors.pink,

      FingerJoint.littleDIP: Colors.cyanAccent,
      FingerJoint.littleMCP: Colors.cyanAccent,
      FingerJoint.littlePIP: Colors.cyanAccent,
      FingerJoint.littleTip: Colors.cyanAccent
    };
    for(int j = 0; j < handData!.length; j++){
      for(int i = 0; i < handData![j].poses.length; i++){
        if(handData![j].poses[i].confidence > 0.5){
          widgets.add(
            Positioned(
              top: handData![j].poses[i].location.y,
              left: handData![j].poses[i].location.x,
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
