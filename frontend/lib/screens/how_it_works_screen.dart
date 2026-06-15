import 'package:flutter/material.dart';
import 'app_layout.dart';
import 'dashboard_screen.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      activeTab: 'How It Works',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: WhyNoSurgeCard(),
        ),
      ),
    );
  }
}
