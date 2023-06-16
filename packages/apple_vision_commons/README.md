# apple\_vision\_commons

A Flutter plugin with common methods used in [apple\_vision](https://github.com/Knightro63/apple_vision).

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/Knightro63/apple_vision):

- [Apple Vision](https://developer.apple.com/documentation/vision) was build only for osx apps.

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/master/AUTHORS) are developers wanted to make a similar plugin to Google's ml kit for macos.

- Apple Vision API are only developed natively for iOS and osx. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `FlutterMethodChannel`, and executed using the Apple Vision API.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. You can run both iOS and/or Android native [example apps by Google](https://github.com/googlesamples/mlkit) and make sure that the issue is not reproducible with their native examples. If you can reproduce the issue in their apps then report the issue to Google. The [authors](https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you find that their example apps are okay and still you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Getting Started

Before you get started read about the requirements and known issues of this plugin [here](https://github.com/flutter-ml/google_ml_kit_flutter#requirements).

## Example app

Find the example for each of the packages in there example folder.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
