import 'package:flutter/material.dart';

class CalendarCellEmptyWidget extends StatelessWidget {
  const CalendarCellEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(51),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}