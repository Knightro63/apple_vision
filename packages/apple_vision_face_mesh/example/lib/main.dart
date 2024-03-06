import 'package:apple_vision_face_mesh/apple_vision_face_mesh.dart';
import 'package:flutter/cupertino.dart';
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
  AppleVisionFaceMeshController visionController = AppleVisionFaceMeshController();
  InsertCamera camera = InsertCamera();
  String? deviceId;
  bool loading = true;
  Size imageSize = const Size(640,640*9/16);

  List<FaceMesh>? faceData;
  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    camera.setupCameras().then((value){
      setState(() {
        loading = false;
      });
      camera.startLiveFeed((InputImage i)async {
        if(i.metadata?.size != null){
          imageSize = i.metadata!.size;
        }
        if(mounted) {
          Uint8List? image = i.bytes;
          await visionController.processImage(image!, i.metadata!.size).then((data){
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
        Container(
          color: Colors.red,
          width: imageSize.width, 
          height: imageSize.height, 
          child: loading?Container():CameraSetup(camera: camera,size: imageSize,)
      ),
      ]+showPoints()
    );
  }

  List<Widget> showPoints(){
    if(faceData == null || faceData!.isEmpty) return[];
    List<Widget> widgets = [];
    
    for(int k = 0; k < faceData!.length;k++){
      List<FacePoint> points = faceData![k].mesh;
 
      for(int j = 0; j < points.length;j++){
        //print(min.width);
        widgets.add(
          Positioned(
            left: points[j].x,
            top: points[j].y,
            child: Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1)
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
