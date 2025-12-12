import 'package:flutter/material.dart';

class ShiftSequenceHeaderWidget extends StatelessWidget {
  const ShiftSequenceHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Последовательность смен:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(3),
            3: FixedColumnWidth(48),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: [
                _buildHeaderCell('Смена *'),
                _buildHeaderCell('Кол-во дней *'),
                _buildHeaderCell('Рабочее время'),
                _buildHeaderCell(''),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}