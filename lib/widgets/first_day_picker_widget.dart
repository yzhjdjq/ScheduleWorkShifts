import 'package:flutter/material.dart';
import 'package:sws/services/services.dart' show S;

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
              labelText: '${S.of(context).firstWorkingDay} *',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text:
                  firstWorkingDay == null
                      ? S.of(context).selectDateHint
                      : '${firstWorkingDay!.day}.${firstWorkingDay!.month}.${firstWorkingDay!.year}',
            ),
            readOnly: true,
          ),
        ),
      ),
    );
  }
}
