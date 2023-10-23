# apple\_vision\_scanner

[![Pub Version](https://img.shields.io/pub/v/apple_vision_scanner)](https://pub.dev/packages/apple_vision_scanner)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision Barcode Scanner is a Flutter plugin that enables Flutter apps to use [Apple Vision Barcode Scanner](https://developer.apple.com/documentation/vision/vnbarcodeobservation).

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Requirements

**MacOS**
 - Minimum osx Deployment Target: 10.13
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

**iOS**
 - Minimum ios Deployment Target: 11.0
 - Xcode 13 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

## Getting Started

You need to first import 'package:apple_vision/apple_vision.dart';

```dart
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  AppleVisionScannerController visionController = AppleVisionScannerController();
  InsertCamera camera = InsertCamera();
  String? deviceId;
  bool loading = true;
  Size imageSize = const Size(640,640*9/16);

  List<Barcode>? barcodeData;
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
            barcodeData = data;
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
          child: loading?Container():CameraSetup(camera: camera,size: imageSize,)
      ),
      ]+showRects()
    );
  }

  List<Widget> showRects(){
    if(barcodeData == null || barcodeData!.isEmpty) return [];
    List<Widget> widgets = [];

    for(int i = 0; i < barcodeData!.length; i++){
      widgets.add(
        Positioned(
          top: barcodeData![i].boundingBox!.top,
          left: barcodeData![i].boundingBox!.left,
          child: Container(
            width: barcodeData![i].boundingBox!.width,
            height: barcodeData![i].boundingBox!.height,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 1, color: Colors.green),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Text(
                '${barcodeData![i].displayValue}: ${barcodeData![i].type}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12
                ),
              ),
          )
        )
      );
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

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_scanner/example/lib/main.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
