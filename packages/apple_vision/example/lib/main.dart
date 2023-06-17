import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apple_vision/apple_vision.dart';
import 'package:camera_macos/camera_macos_controller.dart';
import 'package:camera_macos/camera_macos_device.dart';
import 'package:camera_macos/camera_macos_file.dart';
import 'package:camera_macos/camera_macos_platform_interface.dart';
import 'package:camera_macos/camera_macos_view.dart';


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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const VisionFace(),
    );
  }
}

class VisionFace extends StatefulWidget {
  const VisionFace({
    Key? key,
    this.size = const Size(750,750),
    this.onScanned
  }):super(key: key);

  final Size size;
  final Function(dynamic data)? onScanned; 

  @override
  _VisionFace createState() => _VisionFace();
}

class _VisionFace extends State<VisionFace>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionFaceController cameraController;
  late List<CameraMacOSDevice> _cameras;
  CameraMacOSController? controller;
  String? deviceId;

  FaceData? faceData;
  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    cameraController = AppleVisionFaceController();
    CameraMacOS.instance.listDevices(deviceType: CameraMacOSDeviceType.video).then((value){
      _cameras = value;
      deviceId = _cameras.first.deviceId;
    });
    super.initState();
  }
  @override
  void dispose() {
    controller?.destroy();
    super.dispose();
  }
  void onTakePictureButtonPressed() async{
    CameraMacOSFile? file = await controller?.takePicture();
    if(file != null && mounted) {
      Uint8List? image = file.bytes;
      cameraController.process(image!, const Size(640,480)).then((data){
        faceData = data;
        setState(() {
          
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Stack(
      children:<Widget>[
        SizedBox(
          width: 640, 
          height: 480, 
          child: _getScanWidgetByPlatform()
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

  Widget _getScanWidgetByPlatform() {
    return CameraMacOSView(
      key: cameraKey,
      fit: BoxFit.fill,
      cameraMode: CameraMacOSMode.photo,
      enableAudio: false,
      onCameraLoading: (ob){
        return Container(
          width: deviceWidth,
          height: deviceHeight,
          color: Theme.of(context).canvasColor,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: Colors.blue)
        );
      },
      onCameraInizialized: (CameraMacOSController controller) {
        setState(() {
          this.controller = controller;
          Timer.periodic(const Duration(milliseconds: 32),(_){
            onTakePictureButtonPressed();
          });
        });
      },
    );
  }
}

