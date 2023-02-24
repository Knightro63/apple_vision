import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apple_vision_object/apple_vision_object.dart';
import 'package:camera_macos/camera_macos_controller.dart';
import 'package:camera_macos/camera_macos_device.dart';
import 'package:camera_macos/camera_macos_file.dart';
import 'package:camera_macos/camera_macos_platform_interface.dart';
import 'package:camera_macos/camera_macos_view.dart';

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
  late AppleVisionObjectController cameraController;
  late List<CameraMacOSDevice> _cameras;
  CameraMacOSController? controller;
  String? deviceId;

  ObjectData? faceData;
  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    cameraController = AppleVisionObjectController();
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
    if(faceData == null || faceData!.objects.isEmpty) return[];
    List<Widget> widgets = [];

    for(int i = 0; i < faceData!.objects.length; i++){
      widgets.add(
        Positioned(
          left: faceData!.objects[i].rect.left,
          bottom: faceData!.objects[i].rect.bottom,
          child: Container(
            width: faceData!.objects[i].rect.width,
            height: faceData!.objects[i].rect.height,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(5)
            ),
          )
        )
      );
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