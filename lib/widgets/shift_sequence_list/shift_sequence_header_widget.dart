import 'package:flutter/material.dart';
import 'package:sws/services/services.dart' show S;
import 'package:sws/widgets/shift_sequence_list/shift_sequence_list_columns_width.dart'
    show ShiftSequenceListColumnsWidth;

class ShiftSequenceHeaderWidget extends StatelessWidget {
  const ShiftSequenceHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(ShiftSequenceListColumnsWidth.shiftColumn),
        1: FlexColumnWidth(ShiftSequenceListColumnsWidth.daysColumn),
        2: FlexColumnWidth(ShiftSequenceListColumnsWidth.timeColumn),
        3: FixedColumnWidth(ShiftSequenceListColumnsWidth.removeIconColumn),
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
