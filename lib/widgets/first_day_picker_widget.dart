import 'package:flutter/material.dart';

class FirstDayPickerWidget extends StatelessWidget {
  final DateTime? firstWorkingDay;
  final VoidCallback onTap;

  const FirstDayPickerWidget({super.key, required this.firstWorkingDay, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Первый рабочий день *',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text:
                  firstWorkingDay == null
                      ? 'Выберите дату'
                      : '${firstWorkingDay!.day}.${firstWorkingDay!.month}.${firstWorkingDay!.year}',
            ),
            readOnly: true,
          ),
        ),
      ),
    );
  }
}
