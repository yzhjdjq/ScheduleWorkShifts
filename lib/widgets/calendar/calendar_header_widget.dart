import 'package:flutter/material.dart';

class CalendarHeaderWidget extends StatelessWidget {
  const CalendarHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Container(
      color: Colors.grey.withAlpha(51),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border.symmetric(vertical: BorderSide(color: Colors.white, width: 1)),
              ),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}