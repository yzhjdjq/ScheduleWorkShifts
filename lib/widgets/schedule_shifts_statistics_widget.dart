import 'package:flutter/material.dart';

class ScheduleShiftsStatistics extends StatelessWidget {
  final DateTime _currentDate;

  const ScheduleShiftsStatistics({super.key, required DateTime currentDate}) : _currentDate = currentDate;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;

    return SingleChildScrollView(
      child: Container(
        color: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Календарные дни",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12),
                ),
                Text(
                  daysInMonth.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 8, color: Colors.transparent),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Рабочие дни", style: TextStyle(color: Colors.black, fontSize: 12)),
                Text((daysInMonth - 8).toString(), style: const TextStyle(color: Colors.black, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
