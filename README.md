# Balloon Slider Widget
Balloon slider widget with floating balloon animation, inspired from [Balloon Picker](https://dribbble.com/shots/6609398-Balloon-Picker-in-Swift).

[![pub package](https://img.shields.io/pub/v/flutter_balloon_slider.svg)](https://pub.dartlang.org/packages/flutter_balloon_slider)

## Installation

Add dependency in `pubspec.yaml`:
```yaml
dependencies:
  flutter_balloon_slider: "^0.1.0"
```

Import in your project:
```dart
import 'package:flutter_balloon_slider/flutter_balloon_slider.dart';
```

## Basic usage

```dart
BalloonSlider(
    value: 0.5,
    ropeLength: 55,
    showRope: true,
    onChangeStart: (val) {},
    onChanged: (val) {},
    onChangeEnd: (val) {},
    color: Colors.indigo
)
```

## Examples

[example](https://github.com/faob-dev/flutter_balloon_slider/tree/master/example) project contains demo

### Demo

##### v 0.1.0
![alt tag](https://raw.githubusercontent.com/faob-dev/flutter_balloon_slider/master/screenshots/balloon_slider.gif)

## Changelog
Check [Changelog](https://github.com/faob-dev/flutter_balloon_slider/blob/master/CHANGELOG.md) for updates

## Bugs/Requests
Reporting issues and requests for new features are always welcome.
