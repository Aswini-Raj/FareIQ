import 'package:flutter/material.dart';
import 'app_layout.dart';

class DisputeItem {
  final String id;
  final String reason;
  final String severity;
  final String date;
  String status;

  DisputeItem({
    required this.id,
    required this.reason,
    required this.severity,
    required this.date,
    required this.status,
  });
}

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  final List<DisputeItem> _disputes = [
    DisputeItem(id: 'TRP83921', reason: 'Fare higher than approved band', severity: 'High', date: '10 mins ago', status: 'Under Review'),
    DisputeItem(id: 'TRP83920', reason: 'Incorrect distance computation', severity: 'Medium', date: '25 mins ago', status: 'Open'),
    DisputeItem(id: 'TRP83919', reason: 'Wrong vehicle type classification', severity: 'Low', date: '1 hr ago', status: 'Resolved'),
    DisputeItem(id: 'TRP83918', reason: 'Surge multiplier violation (1.2x)', severity: 'High', date: '2 hrs ago', status: 'Open'),
    DisputeItem(id: 'TRP83917', reason: 'Fuel surcharge mismatch', severity: 'Low', date: '3 hrs ago', status: 'Resolved'),
  ];

  void _resolveDispute(int index) {
    setState(() {
      _disputes[index].status = 'Resolved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dispute ${_disputes[index].id} has been resolved in the ledger.'),
        backgroundColor: kGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      activeTab: 'Disputes',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DISPUTES & COMPLIANCE ANOMALIES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNavy,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review and resolve fare calculations that violated the city regulatory bands.',
                style: TextStyle(fontSize: 12, color: kTextSec),
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _disputes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _disputes[index];
                  return _buildDisputeCard(item, index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisputeCard(DisputeItem item, int index) {
    Color severityColor;
    Color severityBg;
    if (item.severity == 'High') {
      severityColor = kRed;
      severityBg = kRedBg;
    } else if (item.severity == 'Medium') {
      severityColor = kOrange;
      severityBg = kOrangeBg;
    } else {
      severityColor = Colors.blue;
      severityBg = const Color(0xFFEFF6FF);
    }

    Color statusColor;
    Color statusBg;
    if (item.status == 'Resolved') {
      statusColor = kGreen;
      statusBg = kGreenBg;
    } else if (item.status == 'Under Review') {
      statusColor = Colors.purple;
      statusBg = const Color(0xFFF3E8FF);
    } else {
      statusColor = kOrange;
      statusBg = kOrangeBg;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: severityBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: severityColor.withOpacity(0.3)),
            ),
            child: Text(
              item.severity,
              style: TextStyle(fontSize: 10, color: severityColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.id,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kTextPri, fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${item.date}',
                      style: const TextStyle(fontSize: 11, color: kTextHint),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.reason,
                  style: const TextStyle(fontSize: 12, color: kTextSec, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.status,
              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          if (item.status != 'Resolved') ...[
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _resolveDispute(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                minimumSize: const Size(80, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('Resolve', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
