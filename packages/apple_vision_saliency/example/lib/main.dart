import 'package:apple_vision_saliency/apple_vision_saliency.dart';
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
      home: const VisionSaliency(),
    );
  }
}


class VisionSaliency extends StatefulWidget {
  const VisionSaliency({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionSaliency createState() => _VisionSaliency();
}

class _VisionSaliency extends State<VisionSaliency>{
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  late AppleVisionSaliencyController visionController = AppleVisionSaliencyController();
  InsertCamera camera = InsertCamera();
  Size imageSize = const Size(640,640*9/16);
  String? deviceId;
  bool loading = true;

  List<Uint8List?>? saliencyImage;
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
            SaliencySegmentationData(
              image: rgba2bitmap(image!,imageSize.width.toInt(),imageSize.height.toInt()),//image!, 
              imageSize: i.metadata!.size,
              type: SaliencyType.object
            )
          ).then((data){
            saliencyImage = data;
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
        if(saliencyImage?[0] != null) SizedBox(
          width: 320, 
          height: 320*9/16,  
          child: Stack(children: [
            Image.memory(
              saliencyImage![0]!,
              fit: BoxFit.fitHeight,
            )
          ],)
        )
      ]
    );
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