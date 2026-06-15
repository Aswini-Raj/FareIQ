import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fare_provider.dart';
import 'app_layout.dart';
import 'dashboard_screen.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FareProvider>();

    return AppLayout(
      activeTab: 'Driver View',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: DriverCard(provider: p),
        ),
      ),
    );
  }
}
