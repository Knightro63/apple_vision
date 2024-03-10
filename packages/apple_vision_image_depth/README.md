# apple\_vision\_image\_depth

[![Pub Version](https://img.shields.io/pub/v/apple_vision_image_depth)](https://pub.dev/packages/apple_vision_image_depth)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision Depth Detection is a Flutter plugin that enables Flutter apps to use [Apple Vision Image Depth](https://developer.apple.com/documentation/avfoundation/additional_data_capture/capturing_photos_with_depth).

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Requirements

Please go to 'https://ml-assets.apple.com/coreml/models/Image/DepthEstimation/FCRN/FCRN.mlmodel' and save the model in '/Users/${userName}/development/tools/flutter/.pub-cache/hosted/pub.dartlang.org/apple_vision_image_depth-${version}/darwin/Classes'. If this step is not done this api will give an error.

**MacOS**
 - Minimum osx Deployment Target: 10.13
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

**iOS**
 - Minimum ios Deployment Target: 14.0
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

## Getting Started

You need to first import 'package:apple_vision/apple_vision.dart';

```dart
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
```

## Example

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_image_depth/example/lib/main.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
