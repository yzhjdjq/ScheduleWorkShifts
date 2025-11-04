import 'package:flutter/services.dart';

class WidgetService {
  static const platform = MethodChannel('ru.yzhjdjq.sws/widget');

  static Future<void> updateWidget() async {
    try {
      await platform.invokeMethod('updateWidget');
    } on PlatformException catch (e) {
      print("Failed to update widget: '${e.message}'.");
    }
  }
}