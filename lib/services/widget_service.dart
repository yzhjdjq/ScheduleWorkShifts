import 'dart:async' show Timer;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart' show MethodChannel, PlatformException;

class WidgetService {
  static const platform = MethodChannel('ru.yzhjdjq.sws/widget');
  static Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 90_000);

  static Future<void> updateWidget() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      await _updateAndroidDesktopWidget();
    });
  }

  static Future<void> _updateAndroidDesktopWidget() async {
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
