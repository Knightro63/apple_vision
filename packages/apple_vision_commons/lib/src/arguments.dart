import 'package:flutter/material.dart';

/// The start arguments of the scanner.
/// 
/// [size] the size of the image.
/// [textureId] the id of the capture
class AppleVisionArguments {
  /// The output size of the camera.
  /// This value can be used to draw a box in the image.
  final Size size;

  /// The texture id of the capture used internally.
  final int? textureId;

  AppleVisionArguments({
    required this.size,
    this.textureId,
  });
}



