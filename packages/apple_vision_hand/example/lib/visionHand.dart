import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apple_vision_hand/apple_vision_hand.dart';
import 'package:camera_macos/camera_macos_controller.dart';
import 'package:camera_macos/camera_macos_device.dart';
import 'package:camera_macos/camera_macos_file.dart';
import 'package:camera_macos/camera_macos_platform_interface.dart';
import 'package:camera_macos/camera_macos_view.dart';

class VisionHand extends StatefulWidget {
  const VisionHand({
    Key? key,
    this.size = const Size(750,750),
    this.onScanned
  }):super(key: key);

  final Size size;
  final Function(dynamic data)? onScanned; 

  @override
  _VisionHand createState() => _VisionHand();
}

class _VisionHand extends State<VisionHand>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionHandController cameraController;
  late List<CameraMacOSDevice> _cameras;
  CameraMacOSController? controller;
  String? deviceId;

  HandData? poseData;
  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    cameraController = AppleVisionHandController();
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
      if(image != null){
        cameraController.processImage(image, const Size(640,480)).then((data){
          poseData = data;
          setState(() {
            
          });
        });
      }
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