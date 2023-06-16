# apple\_vision\_commons

[![Pub Version](https://img.shields.io/pub/v/appe_vision_commons)](https://pub.dev/packages/apple_vision_commons)
[![analysis](https://github.com/Knightro63/apple_vision/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/apple_vision/actions/)
[![Star on Github](https://img.shields.io/github/stars/Knightro63/apple_vision.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Knightro63/apple_vision)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin with common methods used in [apple\_vision](https://github.com/Knightro63/apple_vision).

**PLEASE READ THIS** before continuing or posting a [new issue](https://github.com/Knightro63/apple_vision):

- [Apple Vision](https://developer.apple.com/documentation/vision) was built only for osx apps.

- This plugin is not sponsor or maintained by Apple. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) are developers who wanted to make a similar plugin to Google's ml kit for macos.

- Apple Vision API in only developed natively for osx. This plugin uses Flutter Platform Channels as explained [here](https://docs.flutter.dev/development/platform-integration/platform-channels).

  Because this plugin uses platform channels, no Machine Learning processing is done in Flutter/Dart, all the calls are passed to the native platform using `FlutterMethodChannel`, and executed using the Apple Vision API.

- Since the plugin uses platform channels, you may encounter issues with the native API. Before submitting a new issue, identify the source of the issue. This plugin is only for osx. The [authors](https://github.com/Knightro63/apple_vision/blob/main/AUTHORS) do not have access to the source code of their native APIs, so you need to report the issue to them. If you have an issue using this plugin, then look at our [closed and open issues](https://github.com/flutter-ml/google_ml_kit_flutter/issues). If you cannot find anything that can help you then report the issue and provide enough details. Be patient, someone from the community will eventually help you.

## Getting Started

This plugin is only needed if you are using one of the other apple_vision plugins available.

## Example app

Find the example for each of the packages in there example folder.

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/apple_vision/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/apple_vision/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/apple_vision/pulls) directly.
