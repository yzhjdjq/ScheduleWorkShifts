import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';

class WidgetService {
  static const platform = MethodChannel('ru.yzhjdjq.sws/widget');

  static Future<void> updateWidget() async {
    try {
      await platform.invokeMethod('updateWidget');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to update widget: '${e.message}'.");
      }
    }
  }
}
