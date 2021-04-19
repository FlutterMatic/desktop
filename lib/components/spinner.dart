import 'package:flutter/material.dart';
import 'dart:math' as math;

class Spinner extends StatefulWidget {
  const Spinner({
    Key? key,
    this.color = Colors.blue,
    this.lineWidth = 3,
    this.size = 40,
    this.duration = const Duration(milliseconds: 1000),
    this.controller,
  }) : super(key: key);

  final Color color;
  final double lineWidth;
  final double size;
  final Duration duration;
  final AnimationController? controller;

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ??
        AnimationController(vsync: this, duration: widget.duration))
      ..addListener(
        () => setState(
          () {},
        ),
      )
      ..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..rotateZ((_animation.value) * math.pi * 2),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          painter: _DualRingPainter(
            paintWidth: widget.lineWidth,
            color: widget.color,
          ),
          child: SizedBox.fromSize(size: Size.square(widget.size)),
        ),
      ),
    );
  }
}

class _DualRingPainter extends CustomPainter {
  _DualRingPainter(
      {this.angle = 90, required double paintWidth, required Color color})
      : ringPaint = Paint()
          ..color = color
          ..strokeWidth = paintWidth
          ..style = PaintingStyle.stroke;

  final Paint ringPaint;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawArc(rect, 0.0, getRadian(angle), false, ringPaint);
    canvas.drawArc(rect, getRadian(180), getRadian(angle), false, ringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) => math.pi / 180 * angle;
}
