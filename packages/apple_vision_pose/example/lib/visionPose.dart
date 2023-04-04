import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apple_vision_pose/apple_vision_pose.dart';
import 'package:camera_macos/camera_macos_controller.dart';
import 'package:camera_macos/camera_macos_device.dart';
import 'package:camera_macos/camera_macos_file.dart';
import 'package:camera_macos/camera_macos_platform_interface.dart';
import 'package:camera_macos/camera_macos_view.dart';

class VisionPose extends StatefulWidget {
  const VisionPose({
    Key? key,
    this.size = const Size(750,750),
    this.onScanned
  }):super(key: key);

  final Size size;
  final Function(dynamic data)? onScanned; 

  @override
  _VisionPose createState() => _VisionPose();
}

class _VisionPose extends State<VisionPose>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionPoseController cameraController;
  late List<CameraMacOSDevice> _cameras;
  CameraMacOSController? controller;
  String? deviceId;

  PoseData? poseData;
  late double deviceWidth;
  late double deviceHeight;
  @override
  void initState() {
    cameraController = AppleVisionPoseController();
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
        poseData = data;
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
        )
      ]+showPoints()
    );
  }

  List<Widget> showPoints(){
    if(poseData == null || poseData!.poses.isEmpty) return[];
    Map<Joint,Color> colors = {
      Joint.rightFoot: Colors.orange,
      Joint.rightLeg: Colors.orange,
      Joint.rightUpLeg: Colors.orange,

      Joint.rightHand: Colors.purple,
      Joint.rightForearm: Colors.purple,\

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
    for(int i = 0; i < poseData!.poses.length; i++){
      if(poseData!.poses[i].confidence > 0.5){
        widgets.add(
          Positioned(
            bottom: poseData!.poses[i].location.y,
            left: poseData!.poses[i].location.x,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[poseData!.poses[i].joint],
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
          Timer.periodic(const Duration(milliseconds: 128),(_){
            onTakePictureButtonPressed();
          });
        });
      },
    );
  }
}