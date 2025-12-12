import 'dart:async' show StreamController;
import 'dart:collection' show Queue;
import 'package:flutter/material.dart';

enum SnackBarMessageType { success, error, warning, info }

class SnackBarMessageData {
  final String text;
  final SnackBarMessageType type;
  final Duration? duration;
  final String? actionLabel;
  final VoidCallback? onAction;

  SnackBarMessageData({required this.text, required this.type, this.duration, this.actionLabel, this.onAction});
}

class SnackBarMessageProvider extends ChangeNotifier {
  final _queue = Queue<SnackBarMessageData>();
  final _controller = StreamController<SnackBarMessageData>.broadcast();
  Stream<SnackBarMessageData> get messageStream => _controller.stream;

  bool _isProcessing = false;

  void show({
    required String text,
    required SnackBarMessageType type,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final message = SnackBarMessageData(
      text: text,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
    _queue.add(message);
    _processQueue();
  }

  void showSuccess(String text, {Duration duration = const Duration(seconds: 3)}) =>
      show(text: text, type: SnackBarMessageType.success, duration: duration);

  void showError(String text, {Duration duration = const Duration(seconds: 3)}) =>
      show(text: text, type: SnackBarMessageType.error, duration: duration);

  void showWarning(String text, {Duration duration = const Duration(seconds: 3)}) =>
      show(text: text, type: SnackBarMessageType.warning, duration: duration);

  void showInfo(String text, {Duration duration = const Duration(seconds: 3)}) =>
      show(text: text, type: SnackBarMessageType.info, duration: duration);

  void _processQueue() {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    final message = _queue.removeFirst();
    _controller.add(message);
  }

  void notifyShowComplete() {
    _isProcessing = false;
    _processQueue();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
