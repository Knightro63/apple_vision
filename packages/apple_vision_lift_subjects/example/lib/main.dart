import 'package:apple_vision_lift_subjects/apple_vision_lift_subjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
      home: const VisionLiftSubjects(),
    );
  }
}

class VisionLiftSubjects extends StatefulWidget {
  const VisionLiftSubjects({
    Key? key,
    this.onScanned
  }):super(key: key);

  final Function(dynamic data)? onScanned; 

  @override
  _VisionLiftSubjects createState() => _VisionLiftSubjects();
}

class _VisionLiftSubjects extends State<VisionLiftSubjects>{
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