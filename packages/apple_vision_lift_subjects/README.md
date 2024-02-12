# apple\_vision\_lift\_subjects

[![Pub Version](https://img.shields.io/pub/v/apple_vision_lift_subject)](https://pub.dev/packages/apple_vision_lift_subject)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision Lift Subject is a Flutter plugin that enables Flutter apps to use [Apple Vision Lift Subject](https://developer.apple.com/videos/play/wwdc2023/10176/#:~:text=To%20add%20subject%20lifting%20with,have%20system%20subject%20lifting%20interactions.).

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Requirements

**MacOS**
 - Minimum osx Deployment Target: 14.0
 - Xcode 15 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

**iOS**
 - In develpoment not yet supported
 - Minimum ios Deployment Target: 17.0
 - Xcode 15 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

## Getting Started

You need to first import 'package:apple_vision/apple_vision.dart';

```dart
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionliftSubjectsController visionController = AppleVisionliftSubjectsController();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<Uint8List?> images = [];
  late double deviceWidth;
  late double deviceHeight;
  Uint8List? bg;
  Uint8List? flowers;
  List<Uint8List?> sepImages = [];
  Point? point;

  @override
  void initState() {
    rootBundle.load('assets/WaterOnTheMoonFull.jpg').then((value){
      bg = value.buffer.asUint8List();
    });
    processImages();
    super.initState();
  }

  void processImages(){
    rootBundle.load('assets/rose.jpg').then((value){
      visionController.processImage(
        LiftedSubjectsData(
          image: value.buffer.asUint8List(),
          imageSize: const Size(640,425),
          crop: true,
        )
      ).then((value){
        if(value != null){
          images.add(value);
          setState(() {});
        }
      });
    });
    rootBundle.load('assets/human.png').then((value){
      visionController.processImage(
        LiftedSubjectsData(
          image: value.buffer.asUint8List(),
          imageSize: const Size(512,512),
          backGround: bg
        )
      ).then((value){
        if(value != null){
          images.add(value);
          setState(() {});
        }
      });
    });
    rootBundle.load('assets/flowers.jpg').then((value){
      flowers = value.buffer.asUint8List();
      onTouch(false);
    });
  }

  void onTouch(bool useSep){
    visionController.processImage(
      LiftedSubjectsData(
        image: flowers!,
        imageSize: const Size(600,400),
        crop: useSep,
        touchPoint: point
      )
    ).then((value){
      if(value != null){
        if(useSep){
          sepImages.add(value);
        }
        else{
          images.add(value);
        }
        setState(() {});
      }
    });
  }

  List<Widget> showImages(){
    List<Widget> widgets = [];

    for(int i = 0; i < images.length; i++){
      if(i == images.length-1&& images[i] != null){
        double w = 600;
        double h = 400;
        widgets.add(
          SizedBox(
            width: w,
            height: h,
            child: GestureDetector(
              onTapDown: (td){
                point = Point(
                  td.localPosition.dx/w,
                  td.localPosition.dy/h
                );
                sepImages = [];
                onTouch(true);
              },
              child: Image.memory(
                images[i]!,
                fit: BoxFit.fitHeight,
              ),
            )
          )
        );
      }
      else if(images[i] != null){
        widgets.add(
          Image.memory(
            images[i]!,
            fit: BoxFit.fitHeight,
          )
        );
      }
    }
    for(int i = 0; i < sepImages.length; i++){
      if(sepImages[i] != null){
        widgets.add(
          Image.memory(
            sepImages[i]!,
            fit: BoxFit.fitHeight,
          )
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return ListView(
      children:<Widget>[
        Wrap(
          children: showImages(),
        )

      ]
    );
  }
```

## Example

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_lift_subject/example/lib/main.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
