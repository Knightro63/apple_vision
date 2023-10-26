# apple\_vision\_image\_classification

[![Pub Version](https://img.shields.io/pub/v/apple_vision_image_classification)](https://pub.dev/packages/apple_vision_image_classification)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision Selfie Detection is a Flutter plugin that enables Flutter apps to use [Apple Vision Image Classification](https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml).

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Requirements

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
  AppleVisionImageClassificationController visionController = AppleVisionImageClassificationController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<Label>? labels;
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
          visionController.processImage(image!, imageSize).then((data){
            labels = data;
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
        Column(children: showLabel(),)
      ]
    );
  }

  List<Widget> showLabel(){
    if(labels == null || labels!.isEmpty) return [];
    List<Widget> widgets = [];

    for(int i = 0; i < labels!.length; i++){
      widgets.add(
        Container(
          width: 320,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Text(
            '${labels![i].label}: ${labels![i].confidence}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12
            ),
          ),
        )
      );
    }
    return widgets;
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

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_image_classification/example/lib/main.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
