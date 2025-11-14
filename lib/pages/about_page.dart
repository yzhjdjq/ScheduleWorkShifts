import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О приложении')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterLogo(size: 80),
              const SizedBox(height: 20),
              const Text('SWS Application', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Версия 0.2.0', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text(
                'График рабочих смен',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text('© 2025 ru.yzhjdjq.sws'),
            ],
          ),
        ),
      ),
    );
  }
}
