import 'package:apple_vision_commons/apple_vision_commons.dart';

/// This class represents an exception thrown by the mobile code.
class AppleVisionException implements Exception {
  const AppleVisionException({
    required this.errorCode,
    this.errorDetails,
  });

  /// The error code of the exception.
  final AppleVisionErrorCode errorCode;

  /// The additional error details that came with the [errorCode].
  final AppleVisionErrorDetails? errorDetails;

  @override
  String toString() {
    if (errorDetails != null && errorDetails?.message != null) {
      return "AppleVisionException: code ${errorCode.name}, message: ${errorDetails?.message}";
    }
    return "AppleVisionException: ${errorCode.name}";
  }
}

/// The raw error details for a [AppleVisionException].
class AppleVisionErrorDetails {
  const AppleVisionErrorDetails({
    this.code,
    this.details,
    this.message,
  });

  /// The error code from the [PlatformException].
  final String? code;

  /// The details from the [PlatformException].
  final Object? details;

  /// The error message from the [PlatformException].
  final String? message;
}
