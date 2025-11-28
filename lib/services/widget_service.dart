import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WidgetService {
  static const platform = MethodChannel('ru.yzhjdjq.sws/widget');

  static Future<void> updateWidget() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await platform.invokeMethod('updateWidget');
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print("Ошибка при обновлении виджета: $e");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Неизвестная ошибка при вызове виджета: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print('Widget update skipped: Not Android platform');
      }
    }
  }
}