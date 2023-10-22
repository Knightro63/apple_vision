import 'package:apple_vision_object/apple_vision_object.dart';
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
      home: const VisionObject(),
    );
  }
}

class VisionObject extends StatefulWidget {
  const VisionObject({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionObject createState() => _VisionObject();
}

class _VisionObject extends State<VisionObject>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  AppleVisionObjectController visionController = AppleVisionObjectController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<ObjectData>? objectData;
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
            objectData = data;
            //ßprint(objectData!.objects);
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
    if(objectData == null || objectData!.isEmpty) return [];
    List<Widget> widgets = [];

    for(int i = 0; i < objectData!.length; i++){
      //if(objectData!.objects[i]. confidence > 0.5){
        widgets.add(
          Positioned(
            top: objectData![i].object.top,
            left: objectData![i].object.left,
            child: Container(
              width: objectData![i].object.width*imageSize.width,
              height: objectData![i].object.height*imageSize.height,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 1, color: Colors.green),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Text(
                '${objectData![i].label}: ${objectData![i].confidence}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12
                ),
              )
            ),
            
          )
        );
      //}
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
