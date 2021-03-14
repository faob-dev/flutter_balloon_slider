import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_balloon_slider/src/render.dart';

//Balloon Slider Widget
class BalloonSlider extends StatefulWidget {
  BalloonSlider(
      {Key? key,
      required this.value,
      this.ropeLength = 0,
      this.showRope = false,
      this.onChangeStart,
      required this.onChanged,
      this.onChangeEnd,
      this.color})
      : assert(value >= 0.0 && value <= 1.0),
        assert(ropeLength >= 0),
        super(key: key);

  //determines currently selected value of slider.
  final double value;

  //length of rope from center of balloon to the center of thumb.
  final double ropeLength;

  //hide and show rope.
  final bool showRope;

  //called when the user starts to select a new value of slider.
  final ValueChanged<double>? onChangeStart;

  //called while the user is selecting a new value of slider.
  final ValueChanged<double> onChanged;

  //called when the user is done selecting a new value of slider.
  final ValueChanged<double>? onChangeEnd;

  //color of balloon slider.
  final Color? color;

  @override
  BalloonSliderState createState() => BalloonSliderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DoubleProperty('value', value));
    properties.add(DoubleProperty('ropeLength', ropeLength));
    properties.add(FlagProperty('showRope', value: showRope, ifFalse: ""));
    properties.add(ObjectFlagProperty<ValueChanged<double>>.has(
        'onChangeStart', onChangeStart));
    properties.add(
        ObjectFlagProperty<ValueChanged<double>>.has('onChanged', onChanged));
    properties.add(ObjectFlagProperty<ValueChanged<double>>.has(
        'onChangeEnd', onChangeEnd));
    properties.add(ColorProperty('color', color));
  }
}

class BalloonSliderState extends State<BalloonSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Timer? animationEndTimer;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    animationEndTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BalloonSliderWidget(
      value: widget.value,
      ropeLength: widget.ropeLength,
      showRope: widget.showRope,
      onChangeStart: widget.onChangeStart,
      onChanged: widget.onChanged,
      onChangeEnd: widget.onChangeEnd,
      color: widget.color,
      state: this,
    );
  }
}
