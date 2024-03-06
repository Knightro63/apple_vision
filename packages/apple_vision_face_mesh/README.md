# apple\_vision\_face\_mesh

[![Pub Version](https://img.shields.io/pub/v/apple_vision_face)](https://pub.dev/packages/apple_vision_face_mesh)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision Face Mesh is a Flutter plugin that enables Flutter apps to use tensor flows Face Mesh.

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Requirements

**MacOS**
 - Minimum osx Deployment Target: 11.0
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

**iOS**
 - Minimum ios Deployment Target: 13.0
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

## Getting Started

You need to first import 'package:apple_vision/apple_vision.dart';

```dart
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
```

## Example

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_face_mesh/example/lib/main.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
