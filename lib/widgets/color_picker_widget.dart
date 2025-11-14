import 'package:flutter/material.dart';

import 'package:sws/models/work_shift.dart' show ShiftCategory, WorkShift;

class ColorPickerWidget extends StatelessWidget {
  final WorkShift _shift;
  final StateSetter _setState;

  const ColorPickerWidget({super.key, required WorkShift shift, required StateSetter setState})
    : _shift = shift,
      _setState = setState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Цвет смены:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Предпросмотр выбранного цвета
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _shift.color,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              _shift.category == ShiftCategory.workingDay ? 'Рабочий день' : 'Выходной',
              style: TextStyle(
                color: _shift.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Градиент для выбора цвета
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: const LinearGradient(
              colors: <Color>[
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: GestureDetector(
            onTapDown: (details) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                final relativeX = localPosition.dx / renderBox.size.width;

                // Преобразование позиции в цвет
                final newColor = _getColorFromPosition(relativeX);
                _setState(() {
                  _shift.color = newColor;
                });
              }
            },
            onPanUpdate: (details) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                final relativeX = localPosition.dx.clamp(0.0, renderBox.size.width) / renderBox.size.width;

                // Преобразование позиции в цвет
                final newColor = _getColorFromPosition(relativeX);
                _setState(() {
                  _shift.color = newColor;
                });
              }
            },
            child: Container(),
          ),
        ),
        const SizedBox(height: 8),

        // Точный выбор через HSLColor
        _buildHslColorPicker(),
      ],
    );
  }

  // Точный выбор цвета через HSL
  Widget _buildHslColorPicker() {
    final hslColor = HSLColor.fromColor(_shift.color);

    return Column(
      children: <Widget>[
        // Ползунок для оттенка (Hue)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Цвет:'),
            Slider(
              value: hslColor.hue,
              min: 0,
              max: 360,
              onChanged: (value) {
                _setState(() {
                  _shift.color = hslColor.withHue(value).toColor();
                });
              },
              activeColor: _shift.color,
            ),
          ],
        ),

        // Ползунок для насыщенности (Saturation)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Насыщенность:'),
            Slider(
              value: hslColor.saturation,
              min: 0,
              max: 1,
              onChanged: (value) {
                _setState(() {
                  _shift.color = hslColor.withSaturation(value).toColor();
                });
              },
              activeColor: _shift.color,
            ),
          ],
        ),

        // Ползунок для светлоты (Lightness)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Яркость:'),
            Slider(
              value: hslColor.lightness,
              min: 0,
              max: 1,
              onChanged: (value) {
                _setState(() {
                  _shift.color = hslColor.withLightness(value).toColor();
                });
              },
              activeColor: _shift.color,
            ),
          ],
        ),
      ],
    );
  }

  // Преобразование позиции в цвет из градиента
  Color _getColorFromPosition(double position) {
    const colors = <Color>[
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    final segment = 1.0 / (colors.length - 1);
    final index = (position / segment).clamp(0, colors.length - 2).floor();
    final localPosition = (position - index * segment) / segment;

    return Color.lerp(colors[index], colors[index + 1], localPosition)!;
  }
}
