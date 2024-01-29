import 'package:apple_vision_recognize_text/apple_vision_recognize_text.dart';
import 'package:flutter/material.dart';
import '../camera/camera_insert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'camera/input_image.dart';

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
      home: const VisionRT(),
    );
  }
}

class VisionRT extends StatefulWidget {
  const VisionRT({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionRT createState() => _VisionRT();
}

class _VisionRT extends State<VisionRT>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  AppleVisionRecognizeTextController visionController = AppleVisionRecognizeTextController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<RecognizedText>? textData;
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
          visionController.processImage(
            image: image!,
            imageSize: imageSize,
            recognitionLevel: RecognitionLevel.accurate,
          ).then((data){
            textData = data;
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
      ]+showRects()
    );
  }

  List<Widget> showRects(){
    if(textData == null || textData!.isEmpty) return [];
    List<Widget> widgets = [];

    for(int i = 0; i < textData!.length; i++){
      widgets.add(
        Positioned(
          top: textData![i].boundingBox.top,
          left: textData![i].boundingBox.left,
          child: Container(
            width: textData![i].boundingBox.width*imageSize.width,
            height: textData![i].boundingBox.height*imageSize.height,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(width: 1, color: Colors.green),
              borderRadius: BorderRadius.circular(5)
            ),
            child: Text(
              textData![i].listText[0],
              style: const TextStyle(fontSize: 8,color: Colors.white),
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
      height:deviceHeight,
      color: Theme.of(context).canvasColor,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Colors.blue)
    );
  }
}
