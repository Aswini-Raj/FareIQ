import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fare_provider.dart';
import 'app_layout.dart';
import 'dashboard_screen.dart';

class AuditLedgerScreen extends StatelessWidget {
  const AuditLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FareProvider>();

    return AppLayout(
      activeTab: 'Audit Ledger',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AuditLedgerCard(provider: p),
        ),
      ),
    );
  }
}
