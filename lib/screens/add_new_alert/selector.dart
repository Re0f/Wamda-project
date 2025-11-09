import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum LineType { continuous, highFreq, lowFreq }

typedef void OnChangeLineType(LineType type);

class LineSelector extends StatefulWidget {
  final OnChangeLineType onChange;
  final LineType? initialValue;

  const LineSelector({required this.onChange, this.initialValue ,super.key});

  @override
  State<LineSelector> createState() => _LineSelectorState();
}

class _LineSelectorState extends State<LineSelector>
    with SingleTickerProviderStateMixin {
  LineType _selected = LineType.continuous;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue ?? LineType.continuous;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _select(LineType t) {
    setState(() {
      _selected = t;
      // adjust speed for visible difference
      widget.onChange(t);
      switch (t) {
        case LineType.continuous:
          _ctrl.duration = const Duration(seconds: 2);
          break;
        case LineType.highFreq:
          _ctrl.duration = const Duration(milliseconds: 600);
          break;
        case LineType.lowFreq:
          _ctrl.duration = const Duration(seconds: 1, milliseconds: 400);
          break;
      }
      _ctrl.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 15),
            Text('Type'.tr()),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeButton('Continuous', LineType.continuous),
                const SizedBox(width: 8),
                _buildTypeButton('High Freq', LineType.highFreq),
                const SizedBox(width: 8),
                _buildTypeButton('Low Freq', LineType.lowFreq),
              ],
            ),
          ),
        ),

        // Drawing area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LinePainter(
                    phase: _ctrl.value * 2 * pi,
                    type: _selected,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, LineType type) {
    final selected = _selected == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.indigo : Colors.grey[300],
        foregroundColor: selected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      onPressed: () => _select(type),
      child: Text(label.tr()),
    );
  }
}

class _LinePainter extends CustomPainter {
  final double phase;
  final LineType type;
  _LinePainter({required this.phase, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // background grid horizontal center
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // draw center line
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), gridPaint);

    // configure painter for waveform
    final Paint paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    // parameters dependent on type
    double amplitude;
    double frequency; // cycles across width
    double baselineShift = 0;

    switch (type) {
      case LineType.continuous:
        amplitude = 0.0;
        frequency = 0.0;
        break;
      case LineType.highFreq:
        amplitude = size.height * 0.22;
        frequency = 6.5; // many oscillations
        break;
      case LineType.lowFreq:
        amplitude = size.height * 0.28;
        frequency = 1.6; // slow oscillations
        break;
    }

    // If continuous, draw smooth baseline / flowing line
    if (type == LineType.continuous) {
      path.moveTo(0, cy);
      // draw a slightly wavy continuous line (very low amplitude)
      for (double x = 0; x <= size.width; x += 1) {
        final double t = x / size.width;
        final double y = cy + sin((t + phase / (2 * pi)) * pi * 2) * 2; // tiny wiggle
        path.lineTo(x, y);
      }
    } else {
      // Wave drawing
      path.moveTo(0, cy);
      for (double x = 0; x <= size.width; x += 1) {
        final double t = x / size.width;
        // sine:  sin(2π * frequency * t + phase)
        final double y = cy + baselineShift + amplitude * sin(2 * pi * frequency * t + phase);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

    // stroke the path
    canvas.drawPath(path, paint);

    // draw small dots at peaks for visual effect (optional)
    final Paint dotPaint = Paint()..color = Colors.white;
    for (double x = 0; x < size.width; x += 8) {
      // find y again (same as above)
      if (type != LineType.continuous) {
        final double t = x / size.width;
        final double y = cy + amplitude * sin(2 * pi * frequency * t + phase);
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) {
    return old.phase != phase || old.type != type;
  }
}