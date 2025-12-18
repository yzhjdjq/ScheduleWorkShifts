import 'package:flutter/material.dart';
import 'package:sws/services/services.dart' show S;

class ShiftSequenceHeaderWidget extends StatelessWidget {
  const ShiftSequenceHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(3),
        3: FixedColumnWidth(48),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _buildHeaderCell('${S.of(context).shift} *'),
            _buildHeaderCell('${S.of(context).numDays} *'),
            _buildHeaderCell(S.of(context).workingTime),
            _buildHeaderCell(''),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
