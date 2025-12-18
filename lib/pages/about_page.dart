import 'package:flutter/material.dart';
import 'package:sws/services/services.dart' show S;
import 'package:sws/sws_metadata.dart' show SwsMetadata;

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).aboutApp)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 80),
              const SizedBox(height: 20),
              Text(S.of(context).swsApplication, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(S.of(context).version(SwsMetadata.appVersion), style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text(
                S.of(context).scheduleWorkShifts,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(S.of(context).copyright),
            ],
          ),
        ),
      ),
    );
  }
}
