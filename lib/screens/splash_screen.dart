import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo/screens/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double percentage = 0.0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: -225, end: 45).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInToLinear,
    ))
      ..addListener(() {
        percentage = ((_animation.value - (-255)) / (45 - (-255))) * 100;
        setState(() {});
      });

    // Start the animation
    _controller.forward();
    // Start a timer for 3 seconds
    Timer(const Duration(seconds: 3), () {
      // Navigate to the Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: SweepGradient(
          colors: [
            Colors.black,
            Colors.white,
            Colors.grey,
            Colors.grey.shade500,
          ],
          endAngle: 40,
          center: Alignment.topRight,
        ),
      ),
      child: SizedBox(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                painter: LogoPainter(needleAngle: _animation.value),
                size: const Size(300, 300),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 30,
                  color: getColor(_animation.value),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  final double needleAngle; // Needle angle in degrees
  LogoPainter({required this.needleAngle});
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final arcWidth = 18.0;
    final outerCirclePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final innerFilledCiclePaint = Paint()..color = Colors.grey.shade300;

    final radius = min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    //inner blur circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      centerY - 40,
      Paint()
        ..color = getColor(needleAngle).withOpacity(0.7)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Draw an incomplete circle (an arc)
    canvas.drawArc(
      rect,
      pi / 4,
      -3 * pi / 2,
      false,
      outerCirclePaint,
    ); // Adjust start and sweep angle
    void _drawArc(Color color, double startAngle, double sweepAngle) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = arcWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      );

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Define the angle ranges for each color
    final greenStartAngle = -225 * pi / 180; // -225 degrees in radians
    final greenSweepAngle = pi / 2; // 90 degrees sweep
    final orangeStartAngle = greenStartAngle + greenSweepAngle; // Follow green
    final orangeSweepAngle = pi / 2; // 90 degrees sweep
    final redStartAngle = orangeStartAngle + orangeSweepAngle; // Follow orange
    final redSweepAngle = pi / 2; // 90 degrees sweep

    // Helper to calculate the sweep for each segment
    double _calculateSweep(double startAngle, double sweepAngle) {
      final needleRadians =
          needleAngle * pi / 180; // Convert needle angle to radians
      if (needleRadians >= startAngle) {
        return min(sweepAngle, needleRadians - startAngle);
      }
      return 0.0; // No sweep if needle hasn't reached this segment
    }

    // Draw dynamic arcs
    _drawArc(Colors.green, greenStartAngle,
        _calculateSweep(greenStartAngle, greenSweepAngle));
    _drawArc(Colors.orange, orangeStartAngle,
        _calculateSweep(orangeStartAngle, orangeSweepAngle));
    _drawArc(Colors.red, redStartAngle,
        _calculateSweep(redStartAngle, redSweepAngle));

    //dashed line
    var outerCircleRadius = radius - 15;
    var innerCircleRadius = radius - 30;

    var dashBrush = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (double i = 45; i >= -225; i -= 5) {
      innerCircleRadius =
          i % 2 != 0 ? innerCircleRadius : innerCircleRadius + 5;
      var x1 = centerX + outerCircleRadius * cos(i * pi / 180);
      var y1 = centerX + outerCircleRadius * sin(i * pi / 180);
      var x2 = centerX + innerCircleRadius * cos(i * pi / 180);
      var y2 = centerX + innerCircleRadius * sin(i * pi / 180);
      innerCircleRadius =
          i % 2 != 0 ? innerCircleRadius : innerCircleRadius - 5;
      if (i % 2 != 0) {
        dashBrush.color = Colors.grey.shade700;
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
      } else {
        dashBrush.color = Colors.grey.shade800;
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
      }
    }
    //     // Needle
    var needlePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    //     // Calculate needle end position
    double needleX = centerX + (radius - 20) * cos(needleAngle * pi / 180);
    double needleY = centerY + (radius - 20) * sin(needleAngle * pi / 180);

    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(needleX, needleY),
      needlePaint,
    );
    //inner circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      10,
      innerFilledCiclePaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      7,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    //inner blur circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      20,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Color getColor(double angle) {
  if (angle >= -225 && angle < -135) {
    return Colors.green;
  } else if (angle >= -135 && angle < -45) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
