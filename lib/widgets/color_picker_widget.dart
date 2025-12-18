import 'package:flutter/material.dart';
import 'package:sws/providers/model_providers/model_providers.dart' show WorkShiftItemViewModel, ShiftCategoryViewModel;
import 'package:sws/services/services.dart' show S;

class ColorPickerWidget extends StatefulWidget {
  final WorkShiftItemViewModel shift;
  final ValueChanged<Color> onColorChanged; // Для редактирования в диалоге
  final VoidCallback? onColorConfirmed; // Вызывается, когда цвет выбран

  const ColorPickerWidget({super.key, required this.shift, required this.onColorChanged, this.onColorConfirmed});

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late HSLColor _hslColor;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.shift.color;
    _hslColor = HSLColor.fromColor(_currentColor);
  }

  @override
  void didUpdateWidget(covariant ColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shift.color != widget.shift.color) {
      _currentColor = widget.shift.color;
      _hslColor = HSLColor.fromColor(_currentColor);
    }
  }

  void _updateColor(HSLColor newHSL) {
    final newColor = newHSL.toColor();
    setState(() {
      _hslColor = newHSL;
      _currentColor = newColor;
    });
    widget.onColorChanged(newColor);
  }

  void _onGradientInteraction(Offset globalPosition) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalPosition);
    final relativeX = localPosition.dx.clamp(0.0, renderBox.size.width) / renderBox.size.width;
    final newColor = _getColorFromPosition(relativeX);
    final newHSL = HSLColor.fromColor(newColor);
    _updateColor(newHSL);
  }

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

  Widget _buildHslSliders() {
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${S.of(context).color}:'),
            Slider(
              value: _hslColor.hue,
              min: 0,
              max: 360,
              onChanged: (value) => _updateColor(_hslColor.withHue(value)),
              activeColor: _currentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${S.of(context).saturation}:'),
            Slider(
              value: _hslColor.saturation,
              min: 0,
              max: 1,
              onChanged: (value) => _updateColor(_hslColor.withSaturation(value)),
              activeColor: _currentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${S.of(context).lightness}:'),
            Slider(
              value: _hslColor.lightness,
              min: 0,
              max: 1,
              onChanged: (value) => _updateColor(_hslColor.withLightness(value)),
              activeColor: _currentColor,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('${S.of(context).shiftColor}:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              widget.shift.category == ShiftCategoryViewModel.workingDay ? S.of(context).workingDay : S.of(context).dayOff,
              style: TextStyle(
                color: _currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
            onTapDown: (details) => _onGradientInteraction(details.globalPosition),
            onPanUpdate: (details) => _onGradientInteraction(details.globalPosition),
            child: Container(),
          ),
        ),
        const SizedBox(height: 8),

        _buildHslSliders(),
      ],
    );
  }
}
