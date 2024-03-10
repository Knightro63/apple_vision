import 'package:apple_vision_image_depth/apple_vision_image_depth.dart';
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
      home: const VisionDepth(),
    );
  }
}

class VisionDepth extends StatefulWidget {
  const VisionDepth({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionDepth createState() => _VisionDepth();
}

class _VisionDepth extends State<VisionDepth>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  AppleVisionImageDepthController visionController = AppleVisionImageDepthController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  Uint8List? image;
  late double deviceWidth;
  late double deviceHeight;

  int intr = 0;

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
          visionController.processImage(ImageDepthData(image:image!, imageSize: imageSize)).then((data){
            this.image = data;
            if(intr == 0){
              intr++;
            }
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
    return ListView(
      children:<Widget>[
        SizedBox(
          width: 320, 
          height: 320*9/16, 
          child: loading?Container():CameraSetup(camera: camera, size: imageSize)
        ),
        if(image != null) SizedBox(
          width: 320, 
          height: 320*9/16,
          child: Image.memory(
            image!, 
            fit: BoxFit.fitHeight,
          )
        )
      ]
    );
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
