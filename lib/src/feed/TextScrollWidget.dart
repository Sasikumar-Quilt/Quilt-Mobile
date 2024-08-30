import 'package:flutter/material.dart';
import 'package:quilt/src/feed/TextScroll.dart';

class TextScrollWidget extends StatefulWidget {
  final String text;
  final double scrollSpeed;
  final bool shouldScroll;

  TextScrollWidget({
    required this.text,
    this.scrollSpeed = 50.0,required this.shouldScroll
  });

  @override
  _TextScrollWidgetState createState() => _TextScrollWidgetState();
}

class _TextScrollWidgetState extends State<TextScrollWidget>{
  late Velocity _velocity;
   ValueNotifier<String>? _textNotifier;

  bool scrollStart=true;

  @override
  void initState() {
    super.initState();
    print("shouldScroll");
    print(widget.shouldScroll);
    _textNotifier= ValueNotifier<String>("Initial Text");
    _updateVelocity();
  }

  @override
  void didUpdateWidget(covariant TextScrollWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    scrollStart=false;
    if (oldWidget.shouldScroll != widget.shouldScroll) {
      _updateVelocity();
    }
  }

  void _updateVelocity() {
    _velocity = Velocity(
      pixelsPerSecond: Offset(50, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  ValueListenableBuilder<String>(
      valueListenable: _textNotifier!,
      builder: (context, value, child) {
        return TextScroll(
        widget.text,
        velocity: _velocity,scrollStart:scrollStart,
        intervalSpaces: 10,
        style: TextStyle(
        color: Color(0xFFFFFDFF),
        fontSize: 30,
        fontFamily: "Causten-Medium",
        ),
        );
      },
    );
  }

}