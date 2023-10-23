import 'dart:typed_data';

import 'package:apple_vision_scanner/apple_vision_scanner.dart';
import 'package:example/camera/camera_insert.dart';
import 'package:example/camera/input_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VisionScanner()
    );
  }
}

class VisionScanner extends StatefulWidget {
  const VisionScanner({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionScanner createState() => _VisionScanner();
}

class _VisionScanner extends State<VisionScanner> {
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
}
