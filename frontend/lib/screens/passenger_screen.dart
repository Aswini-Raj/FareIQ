import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fare_provider.dart';
import 'app_layout.dart';
import 'dashboard_screen.dart';

class PassengerScreen extends StatelessWidget {
  const PassengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FareProvider>();

    return AppLayout(
      activeTab: 'Passenger View',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: PassengerCard(provider: p),
        ),
      ),
    );
  }
}