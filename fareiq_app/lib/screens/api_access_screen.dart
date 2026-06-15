import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fare_provider.dart';
import 'app_layout.dart';
import 'dashboard_screen.dart';

class ApiAccessScreen extends StatelessWidget {
  const ApiAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FareProvider>();

    return AppLayout(
      activeTab: 'API Access',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: PublicApiCard(provider: p),
        ),
      ),
    );
  }
}
