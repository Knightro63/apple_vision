import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos_arguments.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:camera_macos/camera_macos_controller.dart';
import 'package:camera_macos/camera_macos_device.dart';
import 'package:camera_macos/camera_macos_platform_interface.dart';
import 'package:camera_macos/camera_macos_view.dart';
import 'package:permission_handler/permission_handler.dart';

import 'input_image.dart';

class PictureInfo{
  PictureInfo({
    this.file,
    this.error,
  });

  Uint8List? file;
  String? error;
}

class InsertCamera{
  bool restartStream = false;
  bool streaming = false;

  List<CameraDescription> _cameras = [];
  late List<CameraMacOSDevice> _camerasMacos;
  CameraController? controller;
  CameraMacOSController? controllerMacos;

  bool isReady = false;
  //bool isMounted = false;
  Timer? _liveTimerMacos;
  bool _processingLiveMacos = false;
  bool isLive = false;
  double aspectRatio = 0.75;
  int cameraSides = 0;
  int _cameraIndex = 0;
  int cameraRotation = 0;

  Size? imageSize;

  void Function(InputImage image)? _returnImage;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  void dispose(){
    controller?.dispose();
    controllerMacos?.destroy();
  }

  Future<void> setupCameras() async {
    print("Setting up Cameras");
    try {
      if(await Permission.camera.request().isGranted){
        if(Platform.isMacOS){
          await CameraMacOS.instance.listDevices(deviceType: CameraMacOSDeviceType.video).then((value){
            _camerasMacos = value;
            cameraSides = _camerasMacos.length;
          });
          await _setupController(0);
        }
        else{
          print("Checking Cameras");
          _cameras = await availableCameras();
          cameraSides = _cameras.length;
          await _setupController(cameraSides-1);
        }
      }
    }on CameraException catch (_) {
      print('error');
    }
    return;
  }

  Future<void> _setupController(int side) async{
    _cameraIndex = side;
    if(_cameras.isNotEmpty){
      cameraRotation = _cameras[side].sensorOrientation;
    }
    print("Setting up Controller");
    if(isReady){
      await controllerMacos?.destroy();
      await controller?.dispose();
    }
    isReady = false;
    try {
      if(Platform.isMacOS){
        var value = await CameraMacOSPlatform.instance.initialize(
          deviceId: null,
          audioDeviceId: null,
          cameraMacOSMode: CameraMacOSMode.video,
          enableAudio: false,
          resolution: PictureResolution.low,
          pictureFormat: PictureFormat.jpg
        );
        controllerMacos = CameraMacOSController(value!);
        isReady = true;
      }
      else{
        // initialize camera controllers.
        controller = CameraController(
          _cameras[side], 
          ResolutionPreset.low, 
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.bgra8888,
        );
        await controller!.initialize().then((_)async{
          aspectRatio = controller!.value.aspectRatio;
          isReady = true;
        });
      }
    } on CameraException catch (_) {
      print('error');
    }
    return;
  }
  Future stopFeed([int? camera]) async {
    await controller?.stopImageStream();
    await controller?.dispose();
    _liveTimerMacos?.cancel();
    _liveTimerMacos = null;
    isLive = false;
    controller = null;
    if(camera != null){
      _setupController(camera);
    }
  }

  Future startLiveFeed(void Function(InputImage image)? returnImage) async {
    _returnImage = returnImage;
    isLive = true;
    if(Platform.isMacOS){
      controllerMacos?.startImageStream((p){
        imageSize ??= imageSize = Size(p.width.toDouble(), p.height.toDouble());
        InputImage i = InputImage.fromBytes(
          bytes: p.bytes,
          metadata: InputImageMetadata(
            size: imageSize!,
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.bgra8888,
            bytesPerRow: 0,
          )
        );
        _returnImage!(i);
      });
    }
    else{
      controller?.startImageStream(_processCameraImage);
    }
  }
  Future switchCamera(int camera) async {
    await stopFeed(camera);
    if(isLive){
      await startLiveFeed(_returnImage);
    }
  }
  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    _returnImage!(inputImage);
  }
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (controller == null) return null;

    // get camera rotation
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    var rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
  Future<PictureInfo> takePicture() async {
    String? error;
    Uint8List? filePath;
    if(Platform.isMacOS){
      await controllerMacos?.takePicture().then((value){
        if(value != null){
          filePath = value.bytes;
        }
      });
    }
    else{
      if (!controller!.value.isInitialized){
        error = 'Error: select a camera first.';
      }
      else{
        if (controller!.value.isTakingPicture){
          error = "Taking Picture";
        }
        try {
          await controller!.takePicture().then((value) async{
            filePath = await value.readAsBytes();
          });
        } on CameraException catch (e) {
          error = 'Error: ${e.code}\n${e.description}';
        }
      }
    }
    PictureInfo send = PictureInfo(
      file: filePath,
      error: error,
    );
    return send;
  }
}

class CameraSetup extends StatefulWidget {
  const CameraSetup({
    Key? key,
    required this.camera,
    this.size = const Size(640,480)
  }):super(key: key);

  final InsertCamera camera;
  final Size size;

  @override
  _CameraSetupState createState() => _CameraSetupState();
}

class _CameraSetupState extends State<CameraSetup> {
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");

  late CameraController? controller;
  late CameraMacOSController? controllerMacos;
  Offset offset = const Offset(0,0);
  
  @override
  void initState() {
    controller = widget.camera.controller;
    controllerMacos = widget.camera.controllerMacos;
    if(controllerMacos != null){
      // widget.camera.controllerMacos!.args = CameraMacOSArguments(
      //   size: widget.size,
      //   devices: widget.camera.controllerMacos!.args.devices,
      //   textureId: widget.camera.controllerMacos!.args.textureId
      // );
    }
    super.initState();
  }
  @override
  void dispose() async{
    super.dispose();
  }
  Widget _macosCamera() {
    return ClipRect(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: widget.camera.controllerMacos!.args.size.width,
            height: widget.camera.controllerMacos!.args.size.height,
            child: Texture(textureId: widget.camera.controllerMacos!.args.textureId!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(widget.camera.restartStream){
      print('reset Camera Insert');
      widget.camera.restartStream = false;
    }
    return Stack(
      children:[
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: widget.size.height,
            width: widget.size.width,
            child: Platform.isMacOS?_macosCamera():CameraPreview(controller!)
          )
        ),
      ]
    );
  }
}