import 'package:flutter/material.dart';
import 'app_layout.dart';

class RateCardScreen extends StatelessWidget {
  const RateCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      activeTab: 'Rate Card',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CITY APPROVED RATE CARDS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNavy,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Official pricing models set by the transport authority of Chennai.',
                style: TextStyle(fontSize: 12, color: kTextSec),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.45,
                children: [
                  _buildRateCard('Auto Rickshaw', Icons.electric_rickshaw, const Color(0xFFF59E0B), 25.0, 11.0, 1.2),
                  _buildRateCard('Bike Taxi', Icons.two_wheeler, const Color(0xFF10B981), 15.0, 7.0, 0.8),
                  _buildRateCard('Mini Hatchback', Icons.directions_car_filled_outlined, const Color(0xFF3B82F6), 40.0, 14.0, 1.5),
                  _buildRateCard('Sedan', Icons.directions_car_filled, const Color(0xFF8B5CF6), 60.0, 18.0, 2.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateCard(String name, IconData icon, Color accentColor, double base, double perKm, double perMin) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 14),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextPri,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildRateRow('Base Fare', '₹${base.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _buildRateRow('Distance Charge', '₹${perKm.toStringAsFixed(2)} / km'),
          const SizedBox(height: 6),
          _buildRateRow('Time Charge', '₹${perMin.toStringAsFixed(2)} / min'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  'Verified in Ledger Model v2025.10.01',
                  style: TextStyle(
                    fontSize: 9,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kTextSec)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: kTextPri,
          ),
        ),
      ],
    );
  }
}
