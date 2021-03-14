import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_balloon_slider/flutter_balloon_slider.dart';

class BalloonSliderWidget extends LeafRenderObjectWidget {
  final double value;
  final double ropeLength;
  final bool showRope;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color? color;
  final BalloonSliderState state;

  BalloonSliderWidget(
      {Key? key,
      required this.value,
      this.ropeLength = 0,
      this.showRope = false,
      this.onChangeStart,
      required this.onChanged,
      this.onChangeEnd,
      this.color,
      required this.state})
      : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _BalloonSliderRender(
        value: value,
        ropeLength: ropeLength,
        showRope: showRope,
        onChangeStart: onChangeStart,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
        color: color ?? Theme.of(context).primaryColor,
        state: state,
        textDirection: Directionality.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, _BalloonSliderRender renderObject) {
    renderObject
      ..value = value
      ..ropeLength = ropeLength
      ..showRope = showRope
      ..onChangeStart = onChangeStart
      ..onChanged = onChanged
      ..onChangeEnd = onChangeEnd
      ..color = color ?? Theme.of(context).primaryColor
      ..textDirection = Directionality.of(context);
  }
}

class _BalloonSliderRender extends RenderBox {
  _BalloonSliderRender(
      {required double value,
      required Color color,
      double ropeLength = 0,
      bool showRope = false,
      this.onChangeStart,
      required this.onChanged,
      this.onChangeEnd,
      required TextDirection textDirection,
      required BalloonSliderState state})
      : assert(value >= 0.0 && value <= 1.0),
        assert(ropeLength >= 0),
        _value = value,
        _color = color,
        _ropeLength = ropeLength,
        _showRope = showRope,
        _textDirection = textDirection,
        _state = state {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _onDragStart
      ..onUpdate = _onDragUpdate
      ..onEnd = _onDragEnd
      ..onCancel = _onDragCancel;

    _minWidth = 144;
    _minHeight = _trackHeight;

    _buildPaints();
  }

  double get value => _value;
  double _value;

  set value(double val) {
    assert(val >= 0.0 && val <= 1.0);
    if (val == _value) {
      return;
    }
    _value = val;
    markNeedsPaint();
  }

  double get ropeLength => _ropeLength;
  double _ropeLength;

  set ropeLength(double val) {
    assert(val >= 0);
    if (val == _ropeLength) {
      return;
    }
    _ropeLength = val;
    markNeedsPaint();
  }

  bool get showRope => _showRope;
  bool _showRope;

  set showRope(bool val) {
    if (val == _showRope) {
      return;
    }
    _showRope = val;
    markNeedsPaint();
  }

  ValueChanged<double>? onChangeStart;
  ValueChanged<double> onChanged;
  ValueChanged<double>? onChangeEnd;

  Color get color => _color;
  Color _color;

  set color(Color val) {
    if (val == _color) {
      return;
    }
    _color = val;
    _buildPaints();
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection val) {
    if (val == _textDirection) {
      return;
    }
    _textDirection = val;
    markNeedsPaint();
  }

  BalloonSliderState _state;

  bool _active = false;
  double _trackHeight = 4;
  double _currentDragValue = 0.0;

  double _thumbRadius = 10;
  double _balloonScale = 0;
  double? _preBalloonOffsetX;
  final double _balloonWidth = 50;
  final double _balloonHeight = 70;

  late HorizontalDragGestureRecognizer _drag;
  TextPainter _textPainter = TextPainter();
  Path? _balloonPath;
  double _oldValue = -1;
  late double _minWidth;
  late double _minHeight;

  late Paint _trackPaint;
  late Paint _progressPaint;
  late Paint _thumbPaint;
  late Paint _ropePaint;
  late Paint _balloonPaint;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _state.controller.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _state.controller.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Canvas canvas = context.canvas;
    canvas.save();

    //draw track
    Rect trackRect = _getTrackRect(offset: offset);
    canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, Radius.circular((10))), _trackPaint);

    //draw progress
    Rect progressRect = _getTrackRect(offset: offset, progress: _value);
    canvas.drawRRect(RRect.fromRectAndRadius(progressRect, Radius.circular(10)),
        _progressPaint);

    //draw thumb
    Rect thumbRect = _getThumbRect(
        offset: Offset(
            trackRect.left + _value * trackRect.width, trackRect.center.dy));
    canvas.drawCircle(thumbRect.center, _thumbRadius, _thumbPaint);

    //draw balloon
    if (_preBalloonOffsetX == null) {
      _preBalloonOffsetX = thumbRect.center.dx;
    }

    Rect balloonRect = _getBalloonRect(
        offset: Offset(_preBalloonOffsetX! - _balloonWidth / 2, offset.dy),
        parentSize: size);

    double targetOffset = thumbRect.center.dx;
    double diff = thumbRect.center.dx - balloonRect.center.dx;
    var balloonOffsetX = _preBalloonOffsetX! + diff / 10.0;
    if (diff > 0) {
      balloonOffsetX = min(balloonOffsetX, targetOffset);
    } else {
      balloonOffsetX = max(balloonOffsetX, targetOffset);
    }
    double balloonOffsetY = thumbRect.center.dy - balloonRect.center.dy;
    double angle = balloonOffsetY != 0 ? -atan(diff / balloonOffsetY) : 0;
    _preBalloonOffsetX = balloonOffsetX;

    canvas.translate(balloonRect.center.dx, balloonRect.center.dy);

    if (_active) {
      _balloonScale = (_balloonScale + 0.08).clamp(0.0, 1.0);
      canvas.scale(_balloonScale, _balloonScale);
    } else {
      _balloonScale = (_balloonScale - 0.08).clamp(0.0, 1.0);
      canvas.scale(_balloonScale, _balloonScale);
    }

    //draw rope
    if (showRope) {
      canvas.drawLine(
          Offset.zero, thumbRect.center - balloonRect.center, _ropePaint);
    }

    canvas.rotate(angle);

    if (_balloonPath == null) {
      double shiftArc = 20;
      _balloonPath = Path()
        ..arcTo(
            Rect.fromLTWH(-balloonRect.width / 2, -balloonRect.height / 2,
                balloonRect.width, balloonRect.height - shiftArc),
            0,
            -pi,
            false)
        ..quadraticBezierTo(
            -balloonRect.width / 2, 8, -3, balloonRect.height / 2 - 5)
        ..quadraticBezierTo(
            0, balloonRect.height / 2 + 5, 3, balloonRect.height / 2 - 5)
        ..quadraticBezierTo(
            balloonRect.width / 2, 8, balloonRect.width / 2, -shiftArc / 2)
        ..close();
    }

    canvas.drawPath(_balloonPath!, _balloonPaint);
    canvas.rotate(-angle);

    //draw text
    if (_oldValue != _value) {
      final val = (_value * 100).round();
      _textPainter
        ..text = TextSpan(
            text: "$val",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ..textDirection = _textDirection
        ..layout();
    }
    _textPainter.paint(
        canvas, Offset(-_textPainter.width / 2, -_textPainter.height / 2 - 8));
    _oldValue = _value;

    canvas.restore();
  }

  void _onDragStart(DragStartDetails details) {
    if (!_active) {
      if (onChangeStart != null) onChangeStart!(_value);

      Rect _trackRect = _getTrackRect();
      _currentDragValue =
          ((globalToLocal(details.globalPosition).dx - _trackRect.left) /
              _trackRect.width);
      _value = _currentDragValue.clamp(0.0, 1.0);
      onChanged(_value);

      _state.animationEndTimer?.cancel();
      _state.controller.repeat();
      _active = true;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_active) {
      Rect _trackRect = _getTrackRect();
      _currentDragValue += details.primaryDelta! / _trackRect.width;
      final progress = _currentDragValue.clamp(0.0, 1.0);
      if (_value != progress) {
        _value = progress;
        onChanged(_value);
      }
    }
  }

  void _onDragEnd(DragEndDetails details) => _handleDragEnd();

  void _onDragCancel() => _handleDragEnd();

  void _handleDragEnd() {
    if (_active && _state.mounted) {
      if (onChangeEnd != null) onChangeEnd!(_value);

      _state.animationEndTimer?.cancel();
      _state.animationEndTimer = Timer(Duration(milliseconds: 1500), () {
        _state.animationEndTimer = null;
        _balloonScale = 0;
        _state.controller.stop();
      });

      _currentDragValue = 0.0;
      _active = false;
    }
  }

  Rect _getTrackRect({Offset offset = Offset.zero, double progress = 1.0}) =>
      Rect.fromLTWH(
          offset.dx + _thumbRadius,
          offset.dy + (size.height - _trackHeight) / 2,
          (size.width - _thumbRadius * 2) * progress,
          _trackHeight);

  Rect _getBalloonRect(
          {Offset offset = Offset.zero,
          Size parentSize = const Size(0.0, 0.0)}) =>
      Rect.fromLTWH(
          offset.dx,
          offset.dy - ((_balloonHeight - parentSize.height) / 2) - ropeLength,
          _balloonWidth,
          _balloonHeight);

  Rect _getThumbRect({Offset offset = Offset.zero}) =>
      Rect.fromCircle(center: offset, radius: _thumbRadius);

  void _buildPaints() {
    _trackPaint = Paint()..color = _color.withOpacity(0.25);
    _progressPaint = Paint()..color = _color;
    _thumbPaint = Paint()..color = _color;
    _ropePaint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _balloonPaint = Paint()..color = _color;
  }

  @override
  void performResize() {
    size = Size(
        constraints.hasBoundedWidth
            ? constraints.maxWidth
            : _minWidth + _thumbRadius,
        constraints.hasBoundedHeight
            ? constraints.maxHeight
            : _minHeight + _thumbRadius * 2);
  }

  @override
  double computeMinIntrinsicWidth(double height) => _minWidth + _thumbRadius;

  @override
  double computeMaxIntrinsicWidth(double height) => _minWidth + _thumbRadius;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _minHeight + _thumbRadius * 2;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _minHeight + _thumbRadius * 2;

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }
}
