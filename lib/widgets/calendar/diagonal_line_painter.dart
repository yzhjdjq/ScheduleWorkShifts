import 'package:flutter/material.dart' show Canvas, Colors, CustomPainter, Paint, PaintingStyle, Path, Size;

class DiagonalLinePainter extends CustomPainter {
  const DiagonalLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(0, size.height)
          ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
