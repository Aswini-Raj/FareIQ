import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/fare_provider.dart';
import '../widgets/custom_painters.dart';
import 'app_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      activeTab: 'Overview',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner (Responsive)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 800 ? 32 : 20,
                  vertical: constraints.maxWidth > 800 ? 28 : 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E1E38), Color(0xFF1A1A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'FareIQ Launchpad Portal',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Select a portal below to estimate fares, audit compliance, monitor real-time ride logs, or manage settings.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (constraints.maxWidth > 800) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Icon(
                            Icons.dashboard_customize_rounded,
                            size: 72,
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Responsive Grid of screens
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: constraints.maxWidth > 1200
                    ? 4
                    : constraints.maxWidth > 850
                        ? 3
                        : constraints.maxWidth > 550
                            ? 2
                            : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth > 1200
                    ? 0.95
                    : constraints.maxWidth > 850
                        ? 0.9
                        : constraints.maxWidth > 550
                            ? 0.98
                            : 1.8,
                children: [
                  _NavigationCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Passenger View',
                    description: 'Estimate upfront fares, view place autocompletes, choose vehicle types, and check approved fare bands.',
                    route: '/passenger',
                    themeColor: kGreen,
                    bgColor: kGreenBg,
                    imageAsset: 'assets/images/auto.png',
                  ),
                  _NavigationCard(
                    icon: Icons.directions_car_outlined,
                    title: 'Driver View',
                    description: 'Preview exact upfront net earnings, commission deductions, platform fees, and live trip details.',
                    route: '/driver',
                    themeColor: kOrange,
                    bgColor: kOrangeBg,
                    imageAsset: 'assets/images/sedan.png',
                  ),
                  _NavigationCard(
                    icon: Icons.account_balance,
                    title: 'Regulator Dashboard',
                    description: 'Access live oversight analytics, city approved fare bands, compliance radial gauges, and dispute lists.',
                    route: '/regulator',
                    themeColor: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    imageAsset: 'assets/images/regulator_banner.png',
                  ),
                  _NavigationCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Audit Ledger',
                    description: 'Explore the immutable cryptographic ledger with SHA-256 hashes verifying every single fare calculation.',
                    route: '/audit',
                    themeColor: const Color(0xFF1E293B),
                    bgColor: const Color(0xFFF1F5F9),
                    imageAsset: 'assets/images/ledger_banner.png',
                  ),
                  _NavigationCard(
                    icon: Icons.play_circle_outline,
                    title: 'Live Demo',
                    description: 'Simulate live passenger bookings and view real-time synchronization between views.',
                    route: '/live-demo',
                    themeColor: kRed,
                    bgColor: kRedBg,
                  ),
                  _NavigationCard(
                    icon: Icons.credit_card_outlined,
                    title: 'Rate Card',
                    description: 'Review city-regulated baseline parameters for Auto, Bike, Mini, and Sedan classes in real-time.',
                    route: '/rate-card',
                    themeColor: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFCCFBF1),
                  ),
                  _NavigationCard(
                    icon: Icons.gavel_rounded,
                    title: 'Disputes & Claims',
                    description: 'Investigate passenger fare band disputes, check audit ledger hash mismatches, and view logs.',
                    route: '/disputes',
                    themeColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                  ),
                  _NavigationCard(
                    icon: Icons.analytics_outlined,
                    title: 'Reports & Stats',
                    description: 'Generate high-level compliance charts, fare distribution logs, average distance analytics, and exports.',
                    route: '/reports',
                    themeColor: const Color(0xFF4F46E5),
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                  _NavigationCard(
                    icon: Icons.help_outline_rounded,
                    title: 'How It Works',
                    description: 'Discover the transparency protocol detail explaining the dynamic distance, duration, and zero-surge policy.',
                    route: '/how-it-works',
                    themeColor: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFEF3C7),
                  ),
                  _NavigationCard(
                    icon: Icons.code_rounded,
                    title: 'Developer API',
                    description: 'Interact with Swagger documentation, copy REST payloads, and review WebSocket connection strings.',
                    route: '/api-access',
                    themeColor: const Color(0xFFDB2777),
                    bgColor: const Color(0xFFFCE7F3),
                  ),
                  _NavigationCard(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    description: 'Manage your profile, login credentials, and configure simulation settings.',
                    route: '/settings',
                    themeColor: const Color(0xFF475569),
                    bgColor: const Color(0xFFF8FAFC),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final Color themeColor;
  final Color bgColor;
  final String? imageAsset;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    required this.themeColor,
    required this.bgColor,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: themeColor.withOpacity(0.08),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorder, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Gradient Block
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageAsset != null)
                    Image.asset(
                      imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackGradient(),
                    )
                  else
                    _buildFallbackGradient(),
                  
                  // Large background watermark icon for styling (only if no image asset)
                  if (imageAsset == null)
                    Positioned(
                      bottom: -15,
                      right: -15,
                      child: Icon(
                        icon,
                        size: 72,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),

                  // Dark semi-transparent scrim on top for styling
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  
                  // Floating circular icon in the header
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(icon, color: themeColor, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Text Details Block
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: kTextSec,
                          height: 1.25,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Open View',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 11,
                          color: themeColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, themeColor.withOpacity(0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. PASSENGER VIEW CARD
// ═══════════════════════════════════════════════════════════════════════════
class PassengerCard extends StatefulWidget {
  final FareProvider provider;
  const PassengerCard({required this.provider});

  @override
  State<PassengerCard> createState() => PassengerCardState();
}

class PassengerCardState extends State<PassengerCard> {
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _pickupFocus = FocusNode();
  final _dropoffFocus = FocusNode();

  List<ChennaiPlace> _pickupSuggestions = [];
  List<ChennaiPlace> _dropoffSuggestions = [];

  @override
  void initState() {
    super.initState();
    _pickupCtrl.text = widget.provider.pickup;
    _dropoffCtrl.text = widget.provider.dropoff;

    _pickupFocus.addListener(() {
      if (!_pickupFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _pickupSuggestions = []);
            widget.provider.updatePickupAndCalculate(_pickupCtrl.text);
          }
        });
      }
    });

    _dropoffFocus.addListener(() {
      if (!_dropoffFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _dropoffSuggestions = []);
            widget.provider.updateDropoffAndCalculate(_dropoffCtrl.text);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
    super.dispose();
  }

  void _onPickupChanged(String val) {
    setState(() {
      _pickupSuggestions = kChennaiPlaces
          .where((p) => p.name.toLowerCase().contains(val.toLowerCase()))
          .toList();
    });
  }

  void _onDropoffChanged(String val) {
    setState(() {
      _dropoffSuggestions = kChennaiPlaces
          .where((p) => p.name.toLowerCase().contains(val.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final f = p.fare;

    if (_pickupCtrl.text != p.pickup && !_pickupFocus.hasFocus) {
      _pickupCtrl.text = p.pickup;
    }
    if (_dropoffCtrl.text != p.dropoff && !_dropoffFocus.hasFocus) {
      _dropoffCtrl.text = p.dropoff;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: kGreenBg, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded, color: kGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('PASSENGER VIEW', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kGreen)),
                    Text('You see it before you book', style: TextStyle(fontSize: 10, color: kTextSec)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: kGreenBg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 6, color: kGreen),
                    SizedBox(width: 4),
                    Text('Live Update', style: TextStyle(fontSize: 9, color: kGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pickup, Drop, and Map Side-by-Side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Addresses
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PICKUP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: kTextHint)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _pickupCtrl,
                      focusNode: _pickupFocus,
                      onChanged: _onPickupChanged,
                      onSubmitted: (val) => p.updatePickupAndCalculate(val),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on, color: kGreen, size: 16),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                      ),
                    ),
                    if (_pickupSuggestions.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(border: Border.all(color: kBorder), color: Colors.white),
                        child: ListView(
                          shrinkWrap: true,
                          children: _pickupSuggestions.map((place) {
                            return ListTile(
                              dense: true,
                              title: Text(place.name, style: const TextStyle(fontSize: 11)),
                              onTap: () {
                                p.updatePickupAndCalculate(place.name);
                                setState(() {
                                  _pickupCtrl.text = place.name;
                                  _pickupSuggestions = [];
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    const Divider(color: kBorder, height: 12),
                    const Text('DROP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: kTextHint)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _dropoffCtrl,
                      focusNode: _dropoffFocus,
                      onChanged: _onDropoffChanged,
                      onSubmitted: (val) => p.updateDropoffAndCalculate(val),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on, color: kRed, size: 16),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                      ),
                    ),
                    if (_dropoffSuggestions.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(border: Border.all(color: kBorder), color: Colors.white),
                        child: ListView(
                          shrinkWrap: true,
                          children: _dropoffSuggestions.map((place) {
                            return ListTile(
                              dense: true,
                              title: Text(place.name, style: const TextStyle(fontSize: 11)),
                              onTap: () {
                                p.updateDropoffAndCalculate(place.name);
                                setState(() {
                                  _dropoffCtrl.text = place.name;
                                  _dropoffSuggestions = [];
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right Column: Map Mockup
              Container(
                width: 130,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: MinimapPainter(pickup: p.pickup, dropoff: p.dropoff),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle Selector Options
          const Text('SELECT VEHICLE TYPE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: kTextHint)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildVehicleOption(context, p, 'auto', Icons.electric_rickshaw_rounded, 'Auto'),
              const SizedBox(width: 6),
              _buildVehicleOption(context, p, 'bike', Icons.two_wheeler_rounded, 'Bike'),
              const SizedBox(width: 6),
              _buildVehicleOption(context, p, 'mini', Icons.directions_car_filled_rounded, 'Mini'),
              const SizedBox(width: 6),
              _buildVehicleOption(context, p, 'sedan', Icons.local_taxi_rounded, 'Sedan'),
            ],
          ),
          const SizedBox(height: 12),

          // Double-Stacked Specs Chips Row
          Row(
            children: [
              Expanded(child: _buildMetaChip(Icons.straighten_rounded, '${p.distanceKm.toStringAsFixed(1)} km', 'Distance', kGreen)),
              const SizedBox(width: 6),
              Expanded(child: _buildMetaChip(Icons.access_time_rounded, '${p.durationMin.toStringAsFixed(0)} min', 'Est. Time', Colors.blue)),
              const SizedBox(width: 6),
              Expanded(child: _buildMetaChip(Icons.directions_car, p.vehicleType[0].toUpperCase() + p.vehicleType.substring(1), 'Vehicle', Colors.blue)),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: kOrangeBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, size: 10, color: kOrange),
                      SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          'High Demand\nInfo Only',
                          style: TextStyle(fontSize: 8, color: kOrange, fontWeight: FontWeight.bold, height: 1.1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fare breakdown
          const Text('FARE BREAKDOWN (All Inclusive)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextSec)),
          const SizedBox(height: 8),
          if (f != null) ...[
            _buildFareRow('Base Fare', '₹${f.base.toStringAsFixed(2)}'),
            _buildFareRow('Distance Charge (${p.distanceKm} km x ₹${p.currentRates['per_km']!.toStringAsFixed(0)}/km)', '₹${f.distCharge.toStringAsFixed(2)}'),
            _buildFareRow('Time Charge (${p.durationMin.toStringAsFixed(0)} min x ₹${p.currentRates['per_min']!.toStringAsFixed(0)}/min)', '₹${f.timeCharge.toStringAsFixed(2)}'),
            _buildFareRow('Fuel Surcharge (PPAC)', '₹${f.fuelCharge.toStringAsFixed(2)}'),
            const Divider(color: kBorder, height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Fare', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextPri)),
                Text('₹${f.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kGreen)),
              ],
            ),
            const SizedBox(height: 12),

            // Band approval
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CITY APPROVED FARE BAND', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextSec)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: kGreenBg, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Within Band', style: TextStyle(fontSize: 8, color: kGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 20,
              width: double.infinity,
              child: CustomPaint(
                painter: ApprovedBandPainter(minVal: f.bandMin, maxVal: f.bandMax, currentVal: f.total),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${f.bandMin.toStringAsFixed(0)}\nMinimum', style: const TextStyle(fontSize: 8, color: kTextHint), textAlign: TextAlign.center),
                Text('₹${f.total.toStringAsFixed(0)}\nYour Fare', style: const TextStyle(fontSize: 8, color: kGreen, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text('₹${f.bandMax.toStringAsFixed(0)}\nMaximum', style: const TextStyle(fontSize: 8, color: kTextHint), textAlign: TextAlign.center),
              ],
            ),
            const SizedBox(height: 16),

            // Surprise badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: kOrangeBg, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: const [
                  Icon(Icons.verified, color: kOrange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('No Surprise Pricing\nYou pay the same fare, always.', style: TextStyle(fontSize: 9, color: kOrange, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking confirmed! Trip ID: ${f.tripId}'),
                    backgroundColor: kGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confirm Booking   ₹${f.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
          ] else
            const Center(child: CircularProgressIndicator(color: kGreen)),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String value, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kPageBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Text(value, style: const TextStyle(fontSize: 10, color: kTextPri, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 8, color: kTextSec)),
        ],
      ),
    );
  }

  Widget _buildVehicleOption(BuildContext context, FareProvider p, String type, IconData icon, String label) {
    final isSelected = p.vehicleType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          p.updateVehicle(type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? kGreenBg : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? kGreen : kBorder,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kGreen.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? kGreen : kTextSec,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? kGreen : kTextPri,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: kTextSec)),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextPri)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. DRIVER VIEW CARD
// ═══════════════════════════════════════════════════════════════════════════
class DriverCard extends StatelessWidget {
  final FareProvider provider;
  const DriverCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final f = provider.fare;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: kOrangeBg, shape: BoxShape.circle),
                child: const Icon(Icons.directions_car_outlined, color: kOrange, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('DRIVER VIEW', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kOrange)),
                    Text('You see your earnings upfront', style: TextStyle(fontSize: 10, color: kTextSec)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: kOrangeBg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 6, color: kOrange),
                    SizedBox(width: 4),
                    Text('Live Update', style: TextStyle(fontSize: 9, color: kOrange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trip Preview Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPageBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRIP EARNINGS PREVIEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextSec)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Addresses
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: kGreen, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  provider.pickup,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Container(width: 1.5, height: 12, color: kBorder),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: kRed, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  provider.dropoff,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Column: Vehicle & Image
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              provider.vehicleType[0].toUpperCase() + provider.vehicleType.substring(1),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              provider.vehicleType == 'sedan' ? 'assets/images/sedan.png' : 'assets/images/auto.png',
                              height: 55,
                              width: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, size: 44, color: kTextHint),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Specs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpecCell('${provider.distanceKm.toStringAsFixed(1)} km', 'Distance'),
              _buildSpecCell('${provider.durationMin.toStringAsFixed(0)} min', 'Duration'),
              _buildSpecCell(provider.vehicleType[0].toUpperCase() + provider.vehicleType.substring(1), 'Vehicle'),
            ],
          ),
          const SizedBox(height: 16),

          // Earnings breakdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EARNINGS BREAKDOWN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextSec)),
                    const SizedBox(height: 8),
                    if (f != null) ...[
                      _buildEarningsRow('Gross Fare (from passenger)', '₹${f.total.toStringAsFixed(2)}'),
                      _buildEarningsRow('Platform Fee (12%)', '- ₹${f.platformFee.toStringAsFixed(2)}'),
                      _buildEarningsRow('GST (5%)', '- ₹${f.gst.toStringAsFixed(2)}'),
                      _buildEarningsRow('Insurance (1%)', '- ₹${f.insurance.toStringAsFixed(2)}'),
                      const Divider(color: kBorder),
                      const Text('Your Net Earnings', style: TextStyle(fontSize: 10, color: kTextSec)),
                      Text('₹${f.driverNet.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kOrange)),
                    ] else
                      const Center(child: CircularProgressIndicator(color: kOrange)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text('YOU KEEP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextSec)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: CustomPaint(
                      painter: DonutChartPainter(pctKeep: 0.82, activeColor: kOrange),
                      child: const Center(
                        child: Text(
                          '82%',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kTextPri),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(width: 6, height: 6, color: kOrange),
                      const SizedBox(width: 4),
                      const Text('You Keep  82%', style: TextStyle(fontSize: 8, color: kTextSec)),
                    ],
                  ),
                  Row(
                    children: [
                      Container(width: 6, height: 6, color: const Color(0xFFCBD5E1)),
                      const SizedBox(width: 4),
                      const Text('Deductions  18%', style: TextStyle(fontSize: 8, color: kTextSec)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Guarantee badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kOrange.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.security, color: kOrange, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All deductions are shown upfront.\nNo hidden charges. No surprises.',
                    style: TextStyle(fontSize: 9, color: kOrange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trip accepted successfully! Navigation started.'),
                  backgroundColor: kOrange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Accept Trip', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCell(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextPri)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 8, color: kTextHint)),
      ],
    );
  }

  Widget _buildEarningsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: kTextSec)),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextPri)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. REGULATOR DASHBOARD CARD
// ═══════════════════════════════════════════════════════════════════════════
class RegulatorCard extends StatelessWidget {
  final RegulatorProvider regulatorProvider;
  final FareProvider fareProvider;

  const RegulatorCard({required this.regulatorProvider, required this.fareProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('REGULATOR DASHBOARD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
                    Text('Live oversight. Real-time compliance.', style: TextStyle(fontSize: 10, color: kTextSec)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Text('Chennai City', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 12),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: kGreenBg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 6, color: kGreen),
                    SizedBox(width: 4),
                    Text('Live', style: TextStyle(fontSize: 9, color: kGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats horizontal row (instead of 2x2 grid)
          Row(
            children: [
              Expanded(child: _buildRegulatorStatCell('Total Trips (Today)', '24,532', '↑ 12.5%', kGreen)),
              const SizedBox(width: 8),
              Expanded(child: _buildRegulatorStatCell('Within Fare Band', '98.7%', '↑ 2.1%', kGreen)),
              const SizedBox(width: 8),
              Expanded(child: _buildRegulatorStatCell('Disputes Flagged', '12', '↓ 8', kRed)),
              const SizedBox(width: 8),
              Expanded(child: _buildRegulatorStatCell('Avg. Fare', '₹412.65', '↑ 5.3%', kGreen)),
            ],
          ),
          const SizedBox(height: 16),

          // Charts section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FARE DISTRIBUTION (Today)', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: kTextSec)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 70,
                      width: double.infinity,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: BarChartPainter(values: const [0.15, 0.45, 0.9, 0.6, 0.25]),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('₹0-200', style: TextStyle(fontSize: 6, color: kTextHint)),
                        Text('₹200-400', style: TextStyle(fontSize: 6, color: kTextHint)),
                        Text('₹400-600', style: TextStyle(fontSize: 6, color: kTextHint)),
                        Text('₹600-800', style: TextStyle(fontSize: 6, color: kTextHint)),
                        Text('₹800+', style: TextStyle(fontSize: 6, color: kTextHint)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text('COMPLIANCE RATE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: kTextSec)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: CustomPaint(
                      painter: RadialGaugePainter(value: 0.987),
                      child: const Center(
                        child: Text(
                          '98.7%',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextPri),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Within Band', style: TextStyle(fontSize: 8, color: kGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Side-by-side Map and Disputes List
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Trips on Map (Left)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LIVE TRIPS ON MAP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextSec)),
                    const SizedBox(height: 8),
                    Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: RegulatorMapPainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Recent Disputes (Right)
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('RECENT DISPUTES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextSec)),
                        InkWell(
                          onTap: () {},
                          child: const Text('View All', style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildDisputeRow('TRP83921', 'Fare higher than band', 'Under Review', Colors.purple),
                    _buildDisputeRow('TRP83920', 'Incorrect distance', 'Open', kOrange),
                    _buildDisputeRow('TRP83919', 'Wrong vehicle type', 'Resolved', kGreen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Blue Footer Banner with Skyline Vector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '100% Transparency. 100% Accountability.',
                        style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Building trust between citizens, drivers and regulators.',
                        style: TextStyle(fontSize: 8, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 20,
                  child: CustomPaint(
                    painter: SkylinePainter(color: Colors.white24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegulatorStatCell(String label, String value, String rate, Color rateColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: kPageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: kTextSec)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextPri)),
              Text(rate, style: TextStyle(fontSize: 8, color: rateColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeRow(String id, String label, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: kRed, size: 12),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRIP #$id', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  Text(label, style: const TextStyle(fontSize: 8, color: kTextSec)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(
              status,
              style: TextStyle(fontSize: 7, color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. AUDIT LEDGER CARD
// ═══════════════════════════════════════════════════════════════════════════
class AuditLedgerCard extends StatelessWidget {
  final FareProvider provider;
  const AuditLedgerCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final f = provider.fare;
    final tsStr = f != null && f.tsEpoch > 0
        ? DateFormat('dd MMM yyyy, hh:mm:ss a').format(DateTime.fromMillisecondsSinceEpoch(f.tsEpoch * 1000))
        : '25 Oct 2025, 08:45:12 AM';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: kNavy, size: 16),
              const SizedBox(width: 8),
              const Text('AUDIT LEDGER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kNavy)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: kGreenBg, borderRadius: BorderRadius.circular(4)),
                child: const Text('Verified', style: TextStyle(fontSize: 8, color: kGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('TRIP HASH RECORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextSec)),
          const SizedBox(height: 8),
          _buildLedgerRow('Trip ID', f?.tripId ?? 'TRP83921'),
          _buildLedgerRow('Timestamp', tsStr),
          _buildLedgerRow('Distance', '${provider.distanceKm.toStringAsFixed(1)} km'),
          _buildLedgerRow('Duration', '${provider.durationMin.toStringAsFixed(0)} min'),
          _buildLedgerRow('Vehicle Type', provider.vehicleType[0].toUpperCase() + provider.vehicleType.substring(1)),
          _buildLedgerRow('Rate Card Version', f?.rateCardVersion ?? 'v2025.10.01'),
          _buildLedgerRow('Fare Computed', '₹${f?.total.toStringAsFixed(2) ?? "419.00"}'),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hash (SHA-256)', style: TextStyle(fontSize: 9, color: kTextSec)),
              Row(
                children: [
                  Text(
                    f != null && f.fareHash.length > 12
                        ? '${f.fareHash.substring(0, 6)}...${f.fareHash.substring(f.fareHash.length - 6)}'
                        : 'a3f5e2b8c7d9e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8',
                    style: const TextStyle(fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: kTextPri),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: f?.fareHash ?? 'a3f5e2b8c7d9e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hash copied to clipboard!'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: const Icon(Icons.copy, size: 10, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: kBorder, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline, size: 10, color: kGreen),
              SizedBox(width: 4),
              Text('This record is immutable and verifiable.', style: TextStyle(fontSize: 8, color: kGreen, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: kTextSec)),
          Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextPri)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. LIVE DEMO CARD
// ═══════════════════════════════════════════════════════════════════════════
class LiveDemoCard extends StatelessWidget {
  final FareProvider provider;
  const LiveDemoCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final f = provider.fare;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LIVE DEMO - DUAL VIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextPri)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: const [
                    Icon(Icons.bolt, size: 10, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('Live Sync', style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Passenger card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kGreenBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGreen.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Passenger View (Live)', style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 6),
                      const Text('Total Fare', style: TextStyle(fontSize: 8, color: kTextSec)),
                      Text('₹${f?.total.toStringAsFixed(2) ?? "419.00"}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kGreen)),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.sync_alt_rounded, color: kGreen, size: 16),
              ),
              // Driver card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kOrangeBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kOrange.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Driver View (Live)', style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 6),
                      const Text('Your Earnings', style: TextStyle(fontSize: 8, color: kTextSec)),
                      Text('₹${f?.driverNet.toStringAsFixed(2) ?? "343.58"}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kOrange)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Distance:', style: TextStyle(fontSize: 9, color: kTextSec, fontWeight: FontWeight.bold)),
              Text('${provider.distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextPri)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.5,
              activeTrackColor: kGreen,
              inactiveTrackColor: kBorder,
              thumbColor: kGreen,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
            ),
            child: Slider(
              value: provider.distanceKm,
              min: 5.0,
              max: 30.0,
              onChanged: (v) {
                provider.updateDistance(v);
                provider.updateDuration((v * 2.0).clamp(10, 90));
              },
            ),
          ),
          const Center(
            child: Text(
              'Move the slider to see live fare & earnings change!',
              style: TextStyle(fontSize: 7, color: kTextSec, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. WHY NO SURGE CARD
// ═══════════════════════════════════════════════════════════════════════════
class WhyNoSurgeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WHY NO SURGE?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextPri)),
          const SizedBox(height: 10),

          // Circle Cap 1.0 illustration with skyline background
          SizedBox(
            height: 75,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: SurgeGraphicPainter(),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kOrangeBg,
                      border: Border.all(color: kOrange, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('1.0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kOrange)),
                        SizedBox(width: 8),
                        Text('Demand Multiplier\nCapped at 1.0', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextPri, height: 1.1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSurgeBullet('Same fare at 8 AM or 8 PM.'),
          _buildSurgeBullet('High demand? We improve supply, not price.'),
          _buildSurgeBullet('Better routing, not higher pricing.'),
          _buildSurgeBullet('Fair rides for a fair city.'),
          const SizedBox(height: 8),
          
          // Vector City Skyline at bottom of card
          SizedBox(
            height: 30,
            width: double.infinity,
            child: CustomPaint(
              painter: SkylinePainter(color: const Color(0xFFF1F5F9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kGreen, size: 12),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 9, color: kTextSec, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. PUBLIC API CARD
// ═══════════════════════════════════════════════════════════════════════════
class PublicApiCard extends StatelessWidget {
  final FareProvider provider;
  const PublicApiCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final f = provider.fare;
    final Map<String, dynamic> jsonMap = {
      'trip_id': f?.tripId ?? 'TRP83921',
      'timestamp': f != null && f.tsEpoch > 0
          ? DateTime.fromMillisecondsSinceEpoch(f.tsEpoch * 1000).toIso8601String()
          : '2025-10-25T08:45:12Z',
      'distance_km': provider.distanceKm,
      'duration_min': provider.durationMin.toInt(),
      'vehicle_type': provider.vehicleType,
      'rate_card_version': f?.rateCardVersion ?? 'v2025.10.01',
      'fare': f?.total ?? 419.00,
      'hash': f?.fareHash ?? 'a3f5e2b8...',
      'signature': 'MEQCIE...'
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonMap);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PUBLIC AUDIT API', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextPri)),
          const Text('Open. Accessible. Verifiable.', style: TextStyle(fontSize: 9, color: kTextSec)),
          const SizedBox(height: 10),

          // API GET Box
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: kPageBg, border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                const Text('GET', style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'https://api.fareiq.co.in/public/audit/TRP83921',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: kTextPri),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'https://api.fareiq.co.in/public/audit/TRP83921'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Endpoint copied!'), duration: Duration(seconds: 1)),
                    );
                  },
                  child: const Icon(Icons.copy, size: 10, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // JSON Box
          Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kNavyDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                jsonStr,
                style: const TextStyle(color: Color(0xFF34D399), fontFamily: 'monospace', fontSize: 8, height: 1.3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.verified, color: kGreen),
                      SizedBox(width: 10),
                      Text('Ledger Verified', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Text('Audit record ${jsonMap['trip_id']} hash matches the signed signature mathematically on public ledger.', style: const TextStyle(fontSize: 12)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_outlined, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text('Verify Hash', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
