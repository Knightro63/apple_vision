import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:apple_vision_face/apple_vision_face.dart';
import 'package:flutter/material.dart';
import 'package:camera_macos/camera_macos_controller.dart';
import 'package:camera_macos/camera_macos_device.dart';
import 'package:camera_macos/camera_macos_file.dart';
import 'package:camera_macos/camera_macos_platform_interface.dart';
import 'package:camera_macos/camera_macos_view.dart';

import 'package:camera/camera.dart';

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
    this.size = const Size(640,480),
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
  CameraController? iosCameraController;
  String? deviceId;
  bool loading = true;

  FaceData? faceData;
  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    cameraController = AppleVisionFaceController();

    if(Platform.isMacOS){
      CameraMacOS.instance.listDevices(deviceType: CameraMacOSDeviceType.video).then((value){
        _cameras = value;
        deviceId = _cameras.first.deviceId;
      });
    }
    else{

      
    }
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
          width: widget.size.width, 
          height: widget.size.height, 
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

  Future<bool> onCameraInizialized() async{
    Completer<bool> c = Completer<bool>();

      await availableCameras().then((value) async{
        iosCameraController = CameraController(value[0], ResolutionPreset.max);
        print('here');
        await iosCameraController!.initialize().then((value){
          setState(() {
            loading = false;
          });
          c.complete(true);
        }).onError((error, stackTrace){
          c.complete(false);
        });
      });
 
    return c.future;
  }

  Widget loadingWidget(){
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      color: Theme.of(context).canvasColor,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Colors.blue)
    );
  }

  Widget _getScanWidgetByPlatform() {
    return Platform.isMacOS?CameraMacOSView(
      key: cameraKey,
      fit: BoxFit.fill,
      cameraMode: CameraMacOSMode.photo,
      enableAudio: false,
      onCameraLoading: (ob){
        return loadingWidget();
      },
      onCameraInizialized: (CameraMacOSController controller) {
        setState(() {
          this.controller = controller;
          Timer.periodic(const Duration(milliseconds: 64),(_){
            onTakePictureButtonPressed();
          });
        });
      },
    ):FutureBuilder<bool>(
      future: onCameraInizialized(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return loading?loadingWidget():CameraPreview(
          iosCameraController!,
          key: cameraKey,
        );
      }
    );
  }
}
