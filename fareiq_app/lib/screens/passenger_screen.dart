import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/fare_model.dart';
import '../providers/fare_provider.dart';
import '../services/tts_service.dart';

// ─── Color tokens matching the image exactly ───────────────────────────────
const _kNavy       = Color(0xFF1A237E);
const _kGreen      = Color(0xFF1B5E20);
const _kGreenLight = Color(0xFF2E7D32);
const _kGreenBg    = Color(0xFFE8F5E9);
const _kAmber      = Color(0xFFFF9800);
const _kAmberBg    = Color(0xFFFFF3E0);
const _kRed        = Color(0xFFD32F2F);
const _kPageBg     = Color(0xFFF0F2F8);
const _kCardBg     = Colors.white;
const _kBorder     = Color(0xFFE8EAED);
const _kTextPri    = Color(0xFF1C1C1E);
const _kTextSec    = Color(0xFF6B7280);
const _kTextHint   = Color(0xFF9CA3AF);

class PassengerScreen extends StatefulWidget {
  const PassengerScreen({super.key});

  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen>
    with SingleTickerProviderStateMixin {
  final _tts = TtsService();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  bool _ttsPlaying = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(FareBreakdown f, String vehicle) async {
    if (_ttsPlaying) {
      await _tts.stop();
      setState(() => _ttsPlaying = false);
      return;
    }
    setState(() => _ttsPlaying = true);
    await _tts.announceFare(
      total: f.total, base: f.base,
      dist: f.distCharge, time: f.timeCharge,
      fuel: f.fuelCharge, vehicle: vehicle,
    );
    if (mounted) setState(() => _ttsPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FareProvider>();
    final f = p.fare;

    return Scaffold(
      backgroundColor: _kPageBg,
      body: SafeArea(
        child: Column(children: [

          // ── Top bar ────────────────────────────────────────────────────
          _TopBar(
            isConnected: p.isConnected,
            onVoice: f == null ? null : () => _speak(f, p.vehicleType),
            ttsPlaying: _ttsPlaying,
            pulse: _pulse,
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: f == null
              ? const _LoadingState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [

                    // Route card
                    _RouteCard(pickup: p.pickup, dropoff: p.dropoff),
                    const SizedBox(height: 12),

                    // Trip meta chips
                    _TripMetaRow(
                      distKm: p.distanceKm,
                      durMin: p.durationMin,
                      vehicle: p.vehicleType,
                    ),
                    const SizedBox(height: 16),

                    // Sliders
                    _SlidersCard(provider: p),
                    const SizedBox(height: 14),

                    // Vehicle selector
                    _VehicleSelector(
                      selected: p.vehicleType,
                      onSelect: p.updateVehicle,
                    ),
                    const SizedBox(height: 16),

                    // Fare breakdown
                    _FareBreakdownCard(fare: f, provider: p),
                    const SizedBox(height: 14),

                    // Fare band
                    _FareBandCard(fare: f),
                    const SizedBox(height: 14),

                    // No-surge badge
                    _NoSurgeBadge(),
                    const SizedBox(height: 14),

                    // Audit + QR
                    _AuditCard(fare: f),
                  ],
                ),
          ),
        ]),
      ),

      // ── Confirm button fixed at bottom ─────────────────────────────────
      bottomNavigationBar: f == null
          ? null
          : _ConfirmBar(fare: f),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Top Bar
// ═══════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onVoice;
  final bool ttsPlaying;
  final Animation<double> pulse;

  const _TopBar({
    required this.isConnected,
    required this.onVoice,
    required this.ttsPlaying,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kCardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        // FareIQ logo mark
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _kNavy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('F', style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PASSENGER VIEW',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kNavy, letterSpacing: 0.5)),
          Text('You see it before you book',
              style: TextStyle(fontSize: 11, color: _kTextSec)),
        ]),
        const Spacer(),
        // Live dot
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kGreenBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreenLight.withOpacity(0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: _kGreenLight.withOpacity(pulse.value),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isConnected ? 'Live Update' : 'Connecting…',
                style: const TextStyle(fontSize: 11, color: _kGreenLight, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        // TTS button
        GestureDetector(
          onTap: onVoice,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: ttsPlaying ? _kNavy : _kPageBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: Icon(
              ttsPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              size: 18,
              color: ttsPlaying ? Colors.white : _kNavy,
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Route Card
// ═══════════════════════════════════════════════════════════════════════════

class _RouteCard extends StatelessWidget {
  final String pickup, dropoff;
  const _RouteCard({required this.pickup, required this.dropoff});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Pickup
            const Text('PICKUP', style: TextStyle(
              fontSize: 10, color: _kTextHint, letterSpacing: 1, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Row(children: [
              const Icon(Icons.radio_button_checked, color: _kGreenLight, size: 16),
              const SizedBox(width: 6),
              Flexible(child: Text(pickup,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextPri))),
            ]),
            // Dotted connector
            Padding(
              padding: const EdgeInsets.only(left: 7, top: 3, bottom: 3),
              child: Column(children: List.generate(3, (_) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: 2, height: 4,
                decoration: BoxDecoration(
                  color: _kTextHint, borderRadius: BorderRadius.circular(1)),
              ))),
            ),
            // Dropoff
            const Text('DROP', style: TextStyle(
              fontSize: 10, color: _kTextHint, letterSpacing: 1, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Row(children: [
              const Icon(Icons.location_on, color: _kRed, size: 16),
              const SizedBox(width: 6),
              Flexible(child: Text(dropoff,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextPri))),
            ]),
          ]),
        ),
        const SizedBox(width: 12),
        // Mini map placeholder
        Container(
          width: 90, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kGreenLight.withOpacity(0.2)),
          ),
          child: CustomPaint(painter: _MinimapPainter()),
        ),
      ]),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = _kGreenLight.withOpacity(0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.1,
          size.width * 0.8, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.9, size.height * 0.6,
          size.width * 0.7, size.height * 0.85);
    canvas.drawPath(path, road);

    // Start pin
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2),
        5, Paint()..color = _kGreenLight);
    // End pin
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.85),
        5, Paint()..color = _kRed);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// Trip meta chips
// ═══════════════════════════════════════════════════════════════════════════

class _TripMetaRow extends StatelessWidget {
  final double distKm, durMin;
  final String vehicle;
  const _TripMetaRow({required this.distKm, required this.durMin, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, children: [
      _MetaChip(Icons.straighten_rounded,   '${distKm.toStringAsFixed(1)} km'),
      _MetaChip(Icons.access_time_rounded,  '${durMin.toStringAsFixed(0)} min'),
      _MetaChip(Icons.directions_car,       vehicle[0].toUpperCase() + vehicle.substring(1)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _kAmberBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kAmber.withOpacity(0.4)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.info_outline, size: 13, color: Color(0xFFE65100)),
          SizedBox(width: 4),
          Text('High Demand\nInfo Only',
              style: TextStyle(fontSize: 10, color: Color(0xFFE65100),
                  fontWeight: FontWeight.w600, height: 1.3),
              textAlign: TextAlign.center),
        ]),
      ),
    ]);
  }
}

Widget _MetaChip(IconData icon, String label) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _kBorder),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: _kTextSec),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: _kTextSec, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Sliders card
// ═══════════════════════════════════════════════════════════════════════════

class _SlidersCard extends StatelessWidget {
  final FareProvider provider;
  const _SlidersCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final p = provider;
    return _Card(
      child: Column(children: [
        _Slider(
          label: 'Distance',
          unit: 'km',
          value: p.distanceKm,
          min: 1, max: 40,
          divisions: 39,
          onChanged: p.updateDistance,
          color: _kNavy,
        ),
        const SizedBox(height: 10),
        _Slider(
          label: 'Duration',
          unit: 'min',
          value: p.durationMin,
          min: 5, max: 90,
          divisions: 17,
          onChanged: p.updateDuration,
          color: _kAmber,
        ),
      ]),
    );
  }
}

class _Slider extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color color;

  const _Slider({
    required this.label, required this.unit,
    required this.value, required this.min, required this.max,
    required this.divisions, required this.onChanged, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 72,
        child: Text(label, style: const TextStyle(fontSize: 12, color: _kTextSec)),
      ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.15),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value, min: min, max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ),
      Container(
        width: 52, height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text('${value.toStringAsFixed(0)} $unit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Vehicle selector
// ═══════════════════════════════════════════════════════════════════════════

const _vehicles = {
  'auto':  {'icon': Icons.electric_rickshaw, 'label': 'Auto'},
  'bike':  {'icon': Icons.two_wheeler,       'label': 'Bike'},
  'mini':  {'icon': Icons.directions_car,    'label': 'Mini'},
  'sedan': {'icon': Icons.directions_car,    'label': 'Sedan'},
};

class _VehicleSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _VehicleSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _vehicles.entries.map((e) {
        final key = e.key;
        final isSelected = key == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(key);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _kNavy : _kCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _kNavy : _kBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  e.value['icon'] as IconData,
                  size: 20,
                  color: isSelected ? Colors.white : _kTextSec,
                ),
                const SizedBox(height: 4),
                Text(
                  e.value['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : _kTextSec,
                  ),
                ),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Fare Breakdown Card
// ═══════════════════════════════════════════════════════════════════════════

class _FareBreakdownCard extends StatelessWidget {
  final FareBreakdown fare;
  final FareProvider provider;
  const _FareBreakdownCard({required this.fare, required this.provider});

  @override
  Widget build(BuildContext context) {
    final p = provider;
    final rates = p.currentRates;
    final f = fare;

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Card header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Fare Breakdown',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextPri)),
          const Text('All Inclusive',
              style: TextStyle(fontSize: 12, color: _kTextSec)),
        ]),
        const SizedBox(height: 2),
        const Text('Every rupee accounted for',
            style: TextStyle(fontSize: 11, color: _kTextHint)),
        const SizedBox(height: 14),

        // Line items
        _BreakdownRow(
          icon: Icons.home_outlined,
          label: 'Base Fare',
          sublabel: 'Fixed charge',
          amount: f.base,
          color: _kNavy,
        ),
        _divider(),
        _BreakdownRow(
          icon: Icons.route_rounded,
          label: 'Distance Charge',
          sublabel: '${p.distanceKm.toStringAsFixed(1)} km × ₹${rates['per_km']!.toStringAsFixed(0)}/km',
          amount: f.distCharge,
          color: _kNavy,
        ),
        _divider(),
        _BreakdownRow(
          icon: Icons.access_time_rounded,
          label: 'Time Charge',
          sublabel: '${p.durationMin.toStringAsFixed(0)} min × ₹${rates['per_min']!.toStringAsFixed(1)}/min',
          amount: f.timeCharge,
          color: _kNavy,
        ),
        _divider(),
        _BreakdownRow(
          icon: Icons.local_gas_station_rounded,
          label: 'Fuel Surcharge',
          sublabel: 'Live PPAC index',
          amount: f.fuelCharge,
          color: _kNavy,
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, _kBorder, Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Total row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Fare', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kTextPri)),
            Text('No surprise after ride', style: TextStyle(fontSize: 11, color: _kTextHint)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: f.total),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, v, __) => Text(
                '₹${v.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: _kGreenLight),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kGreenBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.check_circle, size: 12, color: _kGreenLight),
                SizedBox(width: 4),
                Text('Within Band',
                    style: TextStyle(fontSize: 11, color: _kGreenLight, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ]),
      ]),
    );
  }

  Widget _divider() => Divider(color: _kBorder.withOpacity(0.7), height: 20);
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final double amount;
  final Color color;

  const _BreakdownRow({
    required this.icon, required this.label,
    required this.sublabel, required this.amount, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kTextPri)),
        Text(sublabel, style: const TextStyle(fontSize: 11, color: _kTextSec)),
      ])),
      Text('₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextPri)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Fare Band Card
// ═══════════════════════════════════════════════════════════════════════════

class _FareBandCard extends StatelessWidget {
  final FareBreakdown fare;
  const _FareBandCard({required this.fare});

  @override
  Widget build(BuildContext context) {
    final f = fare;
    final range = f.bandMax - f.bandMin;
    final pct = range > 0 ? ((f.total - f.bandMin) / range).clamp(0.0, 1.0) : 0.5;

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('City Approved Fare Band',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kTextPri)),
            Text('CMTA regulated — Sedan class',
                style: TextStyle(fontSize: 11, color: _kTextSec)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _kGreenBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreenLight.withOpacity(0.3)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified_rounded, size: 12, color: _kGreenLight),
              SizedBox(width: 4),
              Text('Within Band',
                  style: TextStyle(fontSize: 11, color: _kGreenLight, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),

        // Progress track
        Stack(children: [
          // Background track
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // Filled portion
          FractionallySizedBox(
            widthFactor: pct,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: _kGreenLight,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          // Thumb
          FractionallySizedBox(
            widthFactor: pct,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 14, height: 14,
                decoration: const BoxDecoration(
                  color: _kGreenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, size: 6, color: Colors.white),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),

        // Labels
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _BandLabel('₹${f.bandMin.toStringAsFixed(0)}', 'Minimum', CrossAxisAlignment.start),
          _BandLabel('₹${f.total.toStringAsFixed(0)}', 'Your Fare', CrossAxisAlignment.center,
              isHighlight: true),
          _BandLabel('₹${f.bandMax.toStringAsFixed(0)}', 'Maximum', CrossAxisAlignment.end),
        ]),
      ]),
    );
  }
}

class _BandLabel extends StatelessWidget {
  final String amount, label;
  final CrossAxisAlignment align;
  final bool isHighlight;
  const _BandLabel(this.amount, this.label, this.align, {this.isHighlight = false});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: align,
    children: [
      Text(amount, style: TextStyle(
        fontSize: isHighlight ? 15 : 13,
        fontWeight: FontWeight.w700,
        color: isHighlight ? _kGreenLight : _kTextPri,
      )),
      Text(label, style: const TextStyle(fontSize: 11, color: _kTextSec)),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// No-Surge Badge
// ═══════════════════════════════════════════════════════════════════════════

class _NoSurgeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('1.0×',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('No Surge. Ever.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 3),
          Text('Demand multiplier hard-capped at 1.0. Same fare at 8 AM or 8 PM.',
              style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.4)),
        ])),
        const Icon(Icons.shield_rounded, color: Colors.white70, size: 28),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Audit + QR Card
// ═══════════════════════════════════════════════════════════════════════════

class _AuditCard extends StatefulWidget {
  final FareBreakdown fare;
  const _AuditCard({required this.fare});
  @override
  State<_AuditCard> createState() => _AuditCardState();
}

class _AuditCardState extends State<_AuditCard> {
  bool _showQr = false;

  @override
  Widget build(BuildContext context) {
    final hash = widget.fare.fareHash;
    final shortHash = '${hash.substring(0, 8)}…${hash.substring(hash.length - 6)}';
    final auditUrl = 'https://localhost:8000/api/audit/$hash';

    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _kNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified_user_rounded, size: 16, color: _kNavy),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Audit Ledger', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kTextPri)),
            Text('Immutable · Verifiable · SHA-256', style: TextStyle(fontSize: 11, color: _kTextSec)),
          ])),
          GestureDetector(
            onTap: () => setState(() => _showQr = !_showQr),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _showQr ? _kNavy : _kPageBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kBorder),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.qr_code_rounded, size: 14,
                    color: _showQr ? Colors.white : _kNavy),
                const SizedBox(width: 4),
                Text(_showQr ? 'Hide QR' : 'Show QR',
                    style: TextStyle(fontSize: 11,
                        color: _showQr ? Colors.white : _kNavy,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Hash display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _kPageBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kBorder),
          ),
          child: Row(children: [
            Expanded(child: Text(
              shortHash,
              style: const TextStyle(
                fontSize: 13, fontFamily: 'monospace', color: _kNavy, fontWeight: FontWeight.w600),
            )),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: hash));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hash copied'), duration: Duration(seconds: 2)),
                );
              },
              child: const Icon(Icons.copy_rounded, size: 16, color: _kTextSec),
            ),
          ]),
        ),

        // Rate card version
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.description_outlined, size: 13, color: _kTextHint),
          const SizedBox(width: 5),
          Text('Rate card: ${widget.fare.rateCardVersion}',
              style: const TextStyle(fontSize: 11, color: _kTextHint)),
          const Spacer(),
          const Icon(Icons.lock_rounded, size: 13, color: _kTextHint),
          const SizedBox(width: 4),
          const Text('Tamper-proof', style: TextStyle(fontSize: 11, color: _kTextHint)),
        ]),

        // QR code (expanded)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _showQr ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Center(
              child: Column(children: [
                QrImageView(
                  data: auditUrl,
                  size: 160,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(height: 8),
                const Text('Scan to verify this fare on public ledger',
                    style: TextStyle(fontSize: 11, color: _kTextSec)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confirm Button Bar
// ═══════════════════════════════════════════════════════════════════════════

class _ConfirmBar extends StatelessWidget {
  final FareBreakdown fare;
  const _ConfirmBar({required this.fare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(children: [
        // Price pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _kGreenBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGreenLight.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text('₹${fare.total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kGreenLight)),
            const Text('Total', style: TextStyle(fontSize: 10, color: _kTextSec)),
          ]),
        ),
        const SizedBox(width: 12),
        // Confirm button
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // Navigate to confirmation screen
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _kGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Confirm Booking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Loading state
// ═══════════════════════════════════════════════════════════════════════════

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 48, height: 48,
        child: CircularProgressIndicator(strokeWidth: 3, color: _kNavy),
      ),
      const SizedBox(height: 16),
      const Text('Connecting to FareIQ…', style: TextStyle(fontSize: 14, color: _kTextSec)),
      const SizedBox(height: 6),
      const Text('Fetching live fare from backend', style: TextStyle(fontSize: 12, color: _kTextHint)),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared card wrapper
// ═══════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}