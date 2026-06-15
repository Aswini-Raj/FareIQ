import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fare_provider.dart';
import 'app_layout.dart';
import 'dashboard_screen.dart';

class RegulatorScreen extends StatelessWidget {
  const RegulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FareProvider>();
    final r = context.watch<RegulatorProvider>();

    return AppLayout(
      activeTab: 'Regulator Dashboard',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: RegulatorCard(regulatorProvider: r, fareProvider: p),
        ),
      ),
    );
  }
}
