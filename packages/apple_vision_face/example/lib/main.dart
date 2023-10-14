import 'package:apple_vision_face/apple_vision_face.dart';
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
      home: const VisionFace(),
    );
  }
}

class VisionFace extends StatefulWidget {
  const VisionFace({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionFace createState() => _VisionFace();
}

class _VisionFace extends State<VisionFace> {
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  AppleVisionFaceController visionController = AppleVisionFaceController();
  InsertCamera camera = InsertCamera();
  String? deviceId;
  bool loading = true;
  Size imageSize = const Size(640,640*9/16);

  FaceData? faceData;
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
          visionController.processImage(rgba2bitmap(image!, i.metadata!.size.width.toInt(), i.metadata!.size.height.toInt()) , i.metadata!.size).then((data){
            faceData = data;
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
          child: loading?Container():CameraSetup(camera: camera,size: imageSize,)
      ),
      ]+showPoints()
    );
  }

  List<Widget> showPoints(){
    if(faceData == null || faceData!.marks.isEmpty) return[];
    Map<LandMark,Color> colors = {
      LandMark.faceContour: Colors.amber,
      LandMark.outerLips: Colors.red,
      LandMark.innerLips: Colors.pink,
      LandMark.leftEye: Colors.green,
      LandMark.rightEye: Colors.green,
      LandMark.leftPupil: Colors.purple,
      LandMark.rightPupil: Colors.purple,
      LandMark.leftEyebrow: Colors.lime,
      LandMark.rightEyebrow: Colors.lime,
    };
    List<Widget> widgets = [];

    for(int i = 0; i < faceData!.marks.length; i++){
      List<FacePoint> points = faceData!.marks[i].location;
      for(int j = 0; j < points.length;j++){
        widgets.add(
          Positioned(
            left: points[j].x,
            top: points[j].y,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[faceData!.marks[i].landmark],
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
