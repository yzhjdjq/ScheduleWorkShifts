import 'package:flutter/material.dart';
import 'package:sws/l10n/app_localizations.dart' show AppLocalizations;
import 'package:sws/services/services.dart' show S;

class MonthSwitcherWidget extends StatelessWidget {
  final Color _colorWidget;
  final Color _colorText;
  final DateTime _currentDate;
  final VoidCallback _onNextMonthBtnClicked;
  final VoidCallback _onNowMonthBtnClicked;
  final VoidCallback _onPreviousMonthBtnClicked;

  const MonthSwitcherWidget({
    super.key,
    required Color colorWidget,
    required Color colorText,
    required DateTime currentDate,
    required VoidCallback onNextMonthBtnClicked,
    required VoidCallback onNowMonthBtnClicked,
    required VoidCallback onPreviousMonthBtnClicked,
  }) : _colorWidget = colorWidget,
       _colorText = colorText,
       _currentDate = currentDate,
       _onNextMonthBtnClicked = onNextMonthBtnClicked,
       _onNowMonthBtnClicked = onNowMonthBtnClicked,
       _onPreviousMonthBtnClicked = onPreviousMonthBtnClicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _colorWidget,
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.chevron_left, color: _colorText),
            onPressed: _onPreviousMonthBtnClicked,
          ),
          const Expanded(child: SizedBox()),
          Flexible(
            flex: 2,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _onNowMonthBtnClicked,
                child: Text(
                  _getMonthYearText(S.of(context)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _colorText,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          IconButton(
            icon: Icon(Icons.chevron_right, color: _colorText),
            onPressed: _onNextMonthBtnClicked,
          ),
        ],
      ),
    );
  }

  String _getMonthYearText(AppLocalizations str) {
    List<String> months = <String>[
      str.january,
      str.february,
      str.march,
      str.april,
      str.may,
      str.june,
      str.july,
      str.august,
      str.september,
      str.october,
      str.november,
      str.december,
    ];
    return '${months[_currentDate.month - 1]} ${_currentDate.year}';
  }
}
