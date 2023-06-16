# apple\_vision\_pose

[![Pub Version](https://img.shields.io/pub/v/appe_vision_pose)](https://pub.dev/packages/apple_vision_pose)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision Pose Detection is a Flutter plugin that enables Flutter apps to use [Apple Vision Pose Detection](https://developer.apple.com/documentation/vision/detecting_human_body_poses_in_images).

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Requirements

**MacOS**
 - Minimum osx Deployment Target: 11.0
 - Xcode 13 or newer
 - Swift 5 ß
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

## Getting Started

You need to first import 'package:apple_vision/apple_vision.dart';

```dart
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
```

## Example

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_pose/example/lib/visionPose.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
