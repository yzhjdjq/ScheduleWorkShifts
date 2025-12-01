import 'package:flutter/material.dart' show CustomClipper, Path, Size;

class DiagonalClipper extends CustomClipper<Path> {
  final bool reverse;

  const DiagonalClipper({this.reverse = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (reverse) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
