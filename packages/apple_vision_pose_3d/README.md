# apple\_vision\_pose\_3d

[![Pub Version](https://img.shields.io/pub/v/apple_vision_pose_3d)](https://pub.dev/packages/apple_vision_pose_3d)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision Pose Detection is a Flutter plugin that enables Flutter apps to use [Apple Vision Pose Detection 3D](https://developer.apple.com/documentation/vision/identifying_3d_human_body_poses_in_images).

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Requirements

**MacOS**
 - Minimum osx Deployment Target: 14.0
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

**iOS**
 - Minimum ios Deployment Target: 17.0
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

## Getting Started

You need to first import 'package:apple_vision/apple_vision.dart';

```dart
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionPose3DController visionController = AppleVisionPose3DController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<PoseData3D>? poseData;
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
          visionController.processImage(image!, i.metadata!.size).then((data){
            poseData = data;
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
    if(poseData == null || poseData!.isEmpty) return[];
    Map<Joint3D,Color> colors = {
      Joint3D.rightAnkle: Colors.orange,
      Joint3D.rightKnee: Colors.orange,
      Joint3D.rightHip: Colors.orange,

      Joint3D.rightWrist: Colors.purple,
      Joint3D.rightElbow: Colors.purple,

      Joint3D.rightShoulder: Colors.pink,
      Joint3D.leftShoulder: Colors.pink,

      Joint3D.leftElbow: Colors.indigo,
      Joint3D.leftWrist: Colors.indigo,

      Joint3D.leftHip: Colors.grey,
      Joint3D.leftKnee: Colors.grey,
      Joint3D.leftAnkle: Colors.grey,

      Joint3D.root: Colors.yellow,
      Joint3D.centerShoulder: Colors.yellow,
      Joint3D.spine: Colors.yellow,

      Joint3D.centerHead: Colors.cyanAccent,
      Joint3D.topHead: Colors.cyanAccent
    };
    List<Widget> widgets = [];
    for(int j = 0; j < poseData!.length;j++){
      for(int i = 0; i < poseData![j].poses.length; i++){
        widgets.add(
          Positioned(
            top: imageSize.height-poseData![j].poses[i].location.y * imageSize.height,
            left: poseData![j].poses[i].location.x * imageSize.width,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[poseData![j].poses[i].joint],
                borderRadius: BorderRadius.circular(5)
              ),
            )
          )
        );
      }
    }
    return widgets;
  }
```

## Example

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_pose_3d/example/lib/main.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
