# apple\_vision

[![Pub Version](https://img.shields.io/pub/v/apple_vision)](https://pub.dev/packages/apple_vision)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Apple Vision is a Flutter plugin that enables Flutter apps to use [Apple Vision](https://developer.apple.com/documentation/vision).

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/Knightro63/apple_vision):

- [Apple Vision](https://developer.apple.com/documentation/vision) was built only for osx and ios apps.

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

## Features

### Vision APIs

| Feature                                                                                       | Plugin | Source Code| MacOS | iOS |
|-----------------------------------------------------------------------------------------------|--------|------------|---------|-----|
|[Face Detection Points](https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time)                   | [apple\_vision\_face](https://pub.dev/packages/apple_vision_face) [![Pub Version](https://img.shields.io/pub/v/apple_vision_face)](https://pub.dev/packages/apple_vision_face)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_face)             | ✅ | ✅ |
|[Face Mesh](https://blog.tensorflow.org/2020/03/face-and-hand-tracking-in-browser-with-mediapipe-and-tensorflowjs.html)                   | [apple\_vision\_face\_mesh](https://pub.dev/packages/apple_vision_face_mesh) [![Pub Version](https://img.shields.io/pub/v/apple_vision_face_mesh)](https://pub.dev/packages/apple_vision_face_mesh)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_face_mesh)             | ✅ | ✅ |
|[Face Detection](https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time)                   | [apple\_vision\_face\_detection](https://pub.dev/packages/apple_vision_face_detection) [![Pub Version](https://img.shields.io/pub/v/apple_vision_face_detection)](https://pub.dev/packages/apple_vision_face_detection)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_face_detection)             | ✅ | ✅ |
|[Pose Detection](https://developer.apple.com/documentation/vision/detecting_human_body_poses_in_images)                   | [apple\_vision\_pose](https://pub.dev/packages/apple_vision_pose) [![Pub Version](https://img.shields.io/pub/v/apple_vision_pose)](https://pub.dev/packages/apple_vision_pose)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_pose)             | ✅ | ✅ |
|[Hand Detection](https://developer.apple.com/documentation/vision/detecting_hand_poses_with_vision)                   | [apple\_vision\_hand](https://pub.dev/packages/apple_vision_hand) [![Pub Version](https://img.shields.io/pub/v/apple_vision_hand)](https://pub.dev/packages/apple_vision_hand)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_hand)             | ✅ | ✅ |
|[Hand Detection 3D](https://blog.tensorflow.org/2021/11/3D-handpose.html)                   | [apple\_vision\_hand\_3d](https://pub.dev/packages/apple_vision_hand_3d) [![Pub Version](https://img.shields.io/pub/v/apple_vision_hand)](https://pub.dev/packages/apple_vision_hand_3d)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_hand_3d)             | ✅ | ✅ |
|[Object Classification](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)                   | [apple\_vision\_object](https://pub.dev/packages/apple_vision_object) [![Pub Version](https://img.shields.io/pub/v/apple_vision_object)](https://pub.dev/packages/apple_vision_object)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_object)             | ✅ | ✅ |
|[Object Tracking](https://developer.apple.com/documentation/vision/vntrackobjectrequest)                   | [apple\_vision\_object\_tracking](https://pub.dev/packages/apple_vision_object_tracking) [![Pub Version](https://img.shields.io/pub/v/apple_vision_object_tracking)](https://pub.dev/packages/apple_vision_object_tracking)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_object_tracking)             | ✅ | ✅ |
|[Selfie Segmentation](https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video)                   | [apple\_vision\_selfie](https://pub.dev/packages/apple_vision_selfie) [![Pub Version](https://img.shields.io/pub/v/apple_vision_selfie)](https://pub.dev/packages/apple_vision_selfie)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_selfie)             | ✅ | ✅ |
|[Text Recognition](https://developer.apple.com/documentation/vision/vnrecognizedtextobservation)                   | [apple\_vision\_text\_recognition](https://pub.dev/packages/apple_vision_recognize_text) [![Pub Version](https://img.shields.io/pub/v/apple_vision_recognize_text)](https://pub.dev/packages/apple_vision_recognize_text)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_recognize_text)             | ✅ | ✅ |
|[Image Classification](https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml)                   | [apple\_vision\_image\_classification](https://pub.dev/packages/apple_vision_image_classification) [![Pub Version](https://img.shields.io/pub/v/apple_vision_image_classification)](https://pub.dev/packages/apple_vision_image_classification)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_image_classification)             | ✅ | ✅ |
|[Barcode Scanner](https://developer.apple.com/documentation/vision/vnbarcodeobservation)                   | [apple\_vision\_scanner](https://pub.dev/packages/apple_vision_scanner) [![Pub Version](https://img.shields.io/pub/v/apple_vision_scanner)](https://pub.dev/packages/apple_vision_scanner)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_scanner)             | ✅ | ✅ | [Document Scanner](https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller)                   | [apple_vision_document_scanner](https://pub.dev/packages/apple_vision_document_scanner/) [![Pub Version](https://img.shields.io/pub/v/apple_vision_document_scanner)](https://pub.dev/packages/apple_vision_document_scanner)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/VoVaVc/apple_vision_document_scanner)             | ✅ | ✅ |
|[Animal Pose](https://developer.apple.com/documentation/vision/vndetectanimalbodyposerequest)                   | [apple\_vision\_animal\_pose](https://pub.dev/packages/apple_vision_animal_pose) [![Pub Version](https://img.shields.io/pub/v/apple_vision_animal_pose)](https://pub.dev/packages/apple_vision_animal_pose)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_animal_pose)             | ✅ | ✅ |
|[Pose 3D](https://developer.apple.com/documentation/vision/identifying_3d_human_body_poses_in_images)                   | [apple\_vision\_pose\_3d](https://pub.dev/packages/apple_vision_pose_3d) [![Pub Version](https://img.shields.io/pub/v/apple_vision_pose_3d)](https://pub.dev/packages/apple_vision_pose_3d)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_pose_3d)             | ✅ | ✅ |
|[Saliency](https://developer.apple.com/documentation/vision/vnsaliencyimageobservation)                   | [apple\_vision\_saliency](https://pub.dev/packages/apple_vision_saliency) [![Pub Version](https://img.shields.io/pub/v/apple_vision_saliency)](https://pub.dev/packages/apple_vision_saliency)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_saliency)             | ✅ | ✅ |
|[Lift Subjects](https://developer.apple.com/documentation/vision/vnsaliencyimageobservation)                   | [apple\_vision\_lift\_subjects](https://pub.dev/packages/apple_vision_lift_subjects) [![Pub Version](https://img.shields.io/pub/v/apple_vision_lift_subjects)](https://pub.dev/packages/apple_vision_lift_subjects)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_lift_subjects)             | ✅ | ✅ |
|[Image Depth](https://developer.apple.com/documentation/avfoundation/additional_data_capture/capturing_photos_with_depth)                   | [apple\_vision\_image\_depth](https://pub.dev/packages/apple_vision_image_depth) [![Pub Version](https://img.shields.io/pub/v/apple_vision_image_depth)](https://pub.dev/packages/apple_vision_image_depth)                                        | [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Knightro63/apple_vision/tree/master/packages/apple_vision_image_depth)             | ✅ | ✅ |                                      

## Requirements

**MacOS**
 - Minimum os Deployment Target: 15.0
 - Xcode 15 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

**iOS**
 - Minimum os Deployment Target: 17.0
 - Xcode 15 or newer
 - Swift 5
 - ML Kit only supports 64-bit architectures (x86_64 and arm64).

## Getting Started

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/Knightro63/apple_vision):

- [Apple Vision](https://developer.apple.com/documentation/vision) was built only for osx apps with the intention on making it available for iOS in future releases.

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

- Apple Vision API in only developed natively for osx. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `FlutterMethodChannel`, and executed using the Apple Vision API.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. This plugin is only for osx. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Example

You need to first import 'package:apple_vision/apple_vision.dart';

```dart
final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
AppleVisionFaceController visionController = AppleVisionFaceController();
InsertCamera camera = InsertCamera();
String? deviceId;
bool loading = true;
Size imageSize = const Size(640,640*9/16);

List<FaceData>? faceData;
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
      SizedBox(
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
  Map<LandMark,Color> colors = {
    LandMark.faceContour: Colors.amber,
    LandMark.outerLips: Colors.red,
    LandMark.innerLips: Colors.pink,
    LandMark.leftEye: Colors.green,
    LandMark.rightEye: Colors.green,
    LandMark.leftPupil: Colors.purple,
    LandMark.rightPupil: Colors.purple,
    LandMark.leftEyebrow: Colors.lime,
    LandMark.rightEyebrow: Colors.lime,
  };

  for(int k = 0; k < faceData!.length;k++){
    if(faceData![k].marks.isNotEmpty){
      for(int i = 0; i < faceData![k].marks.length; i++){
        List<FacePoint> points = faceData![k].marks[i].location;
        for(int j = 0; j < points.length;j++){
          widgets.add(
            Positioned(
              left: points[j].x,
              top: points[j].y,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[faceData![k].marks[i].landmark],
                  borderRadius: BorderRadius.circular(5)
                ),
              )
            )
          );
        }
      }
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

Find the example for this API [here](https://github.com/Knightro63/apple_vision/tree/main/packages/apple_vision_pose/example/lib/visionPose.dart).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
