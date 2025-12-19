import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show WatchContext;
import 'package:sws/providers/providers.dart'
    show SnackBarMessageProvider, SnackBarMessageData, SnackBarMessageType;

class SnackBarHandler extends StatelessWidget {
  final Widget child;

  const SnackBarHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SnackBarMessageProvider>();

    return StreamBuilder<SnackBarMessageData>(
      stream: provider.messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(context, snapshot.data!, provider);
          });
        }
        return child;
      },
    );
  }

  void _showSnackBar(
    BuildContext context,
    SnackBarMessageData message,
    SnackBarMessageProvider provider,
  ) {
    final theme = Theme.of(context);
    Color backgroundColor;

    switch (message.type) {
      case SnackBarMessageType.success:
        backgroundColor = Colors.green.shade600;
        break;
      case SnackBarMessageType.error:
        backgroundColor = Colors.red.shade600;
        break;
      case SnackBarMessageType.warning:
        backgroundColor = Colors.orange.shade600;
        break;
      case SnackBarMessageType.info:
        backgroundColor = theme.primaryColor;
        break;
    }

    final snackBar = SnackBar(
      content: Text(message.text, style: const TextStyle(color: Colors.white)),
      duration: message.duration ?? const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
          bottom: Radius.circular(15),
        ),
      ),
      backgroundColor: backgroundColor,
      action:
          message.actionLabel != null
              ? SnackBarAction(
                label: message.actionLabel!,
                textColor: Colors.white,
                onPressed: message.onAction ?? () {},
              )
              : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
      provider.notifyShowComplete();
    });
  }
}
