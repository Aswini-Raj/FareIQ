import 'package:flutter/material.dart';
import 'app_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      activeTab: 'Settings',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextPri)),
              const SizedBox(height: 16),
              const Divider(color: kBorder),
              const SizedBox(height: 16),
              _buildSettingsRow('Blockchain Integration', 'Enabled (SHA-256 Ledger)'),
              _buildSettingsRow('Rate Card Model', 'Chennai City Approved v2025.10.01'),
              _buildSettingsRow('WebSocket Feed', 'ws://localhost:8000/ws/live'),
              _buildSettingsRow('Default Vehicle Type', 'Sedan'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kTextSec)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kGreenLight)),
        ],
      ),
    );
  }
}
