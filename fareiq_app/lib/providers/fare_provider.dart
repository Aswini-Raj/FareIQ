import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/fare_model.dart';
import '../services/websocket_service.dart';

class ChennaiPlace {
  final String name;
  final double lat;
  final double lng;

  const ChennaiPlace(this.name, this.lat, this.lng);
}

const List<ChennaiPlace> kChennaiPlaces = [
  ChennaiPlace('T. Nagar, Chennai', 13.0418, 80.2337),
  ChennaiPlace('OMR, Sholinganallur', 12.9010, 80.2279),
  ChennaiPlace('Adyar, Chennai', 13.0033, 80.2550),
  ChennaiPlace('Velachery, Chennai', 12.9802, 80.2228),
  ChennaiPlace('Guindy, Chennai', 13.0067, 80.2206),
  ChennaiPlace('Marina Beach, Chennai', 13.0475, 80.2824),
  ChennaiPlace('Chennai Central Railway Station', 13.0827, 80.2707),
  ChennaiPlace('Chennai International Airport', 12.9941, 80.1709),
  ChennaiPlace('Koyambedu, Chennai', 13.0692, 80.1943),
  ChennaiPlace('Nungambakkam, Chennai', 13.0587, 80.2356),
  ChennaiPlace('Mylapore, Chennai', 13.0330, 80.2673),
  ChennaiPlace('Tambaram, Chennai', 12.9237, 80.1472),
  ChennaiPlace('Besant Nagar, Chennai', 13.0003, 80.2667),
  ChennaiPlace('Anna Nagar, Chennai', 13.0850, 80.2101),
  ChennaiPlace('Porur, Chennai', 13.0382, 80.1565),
  ChennaiPlace('Chromepet, Chennai', 12.9616, 80.1372),
];

class FareProvider extends ChangeNotifier {
  final _ws = WebSocketService();

  FareBreakdown? fare;
  bool isLoading = true;
  bool isConnected = false;
  bool isSidebarOpen = true;

  // In-memory Auth State
  final Map<String, String> _users = {
    'passenger@fareiq.com': 'password',
    'driver@fareiq.com': 'password',
    'regulator@fareiq.com': 'password',
  };
  final Map<String, Map<String, String>> _profiles = {
    'passenger@fareiq.com': {'name': 'Arun Kumar', 'role': 'passenger'},
    'driver@fareiq.com': {'name': 'Rajesh Kannan', 'role': 'driver'},
    'regulator@fareiq.com': {'name': 'CMTA Officer', 'role': 'regulator'},
  };
  Map<String, String>? currentUser; // Holds current logged in user: name, email, role

  bool register(String name, String email, String password, String role) {
    if (_users.containsKey(email)) return false;
    _users[email] = password;
    _profiles[email] = {
      'name': name,
      'role': role,
    };
    notifyListeners();
    return true;
  }

  bool login(String email, String password) {
    if (_users[email] == password) {
      currentUser = _profiles[email] != null 
          ? Map<String, String>.from(_profiles[email]!) 
          : {'name': 'User', 'role': 'passenger'};
      currentUser!['email'] = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void toggleSidebar() {
    isSidebarOpen = !isSidebarOpen;
    notifyListeners();
  }

  // Trip params — these drive the sliders
  double distanceKm  = 18.6;
  double durationMin = 36.0;
  String vehicleType = 'sedan';
  double demandIndex = 1.0; // always capped at 1.0 — no surge

  // Route info
  String pickup = 'T. Nagar, Chennai';
  String dropoff = 'OMR, Sholinganallur';

  void updatePickupAndCalculate(String placeName) {
    pickup = placeName;
    _calculateDynamicDistanceAndDuration();
    notifyListeners();
  }

  void updateDropoffAndCalculate(String placeName) {
    dropoff = placeName;
    _calculateDynamicDistanceAndDuration();
    notifyListeners();
  }

  void _calculateDynamicDistanceAndDuration() {
    if (pickup.trim().isEmpty || dropoff.trim().isEmpty) return;

    ChennaiPlace? p1;
    ChennaiPlace? p2;
    for (var p in kChennaiPlaces) {
      if (p.name.toLowerCase().trim() == pickup.toLowerCase().trim()) p1 = p;
      if (p.name.toLowerCase().trim() == dropoff.toLowerCase().trim()) p2 = p;
    }
    
    if (p1 != null && p2 != null) {
      const earthRadius = 6371.0; // in km
      final dLat = (p2.lat - p1.lat) * math.pi / 180.0;
      final dLng = (p2.lng - p1.lng) * math.pi / 180.0;
      
      final a = math.sin(dLat / 2.0) * math.sin(dLat / 2.0) +
                math.cos(p1.lat * math.pi / 180.0) * math.cos(p2.lat * math.pi / 180.0) *
                math.sin(dLng / 2.0) * math.sin(dLng / 2.0);
      
      final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
      final straightDistance = earthRadius * c;
      
      // Real city road routing multiplier (1.35x straight line)
      double dist = straightDistance * 1.35;
      if (dist < 1.0) dist = 1.0;
      if (dist > 150.0) dist = 150.0;
      
      // Average city travel duration (approx 2.0 mins per km + 3 mins default traffic buffering)
      double dur = dist * 2.0 + 3.0;
      if (dur < 5.0) dur = 5.0;
      if (dur > 240.0) dur = 240.0;
      
      distanceKm = double.parse(dist.toStringAsFixed(1));
      durationMin = double.parse(dur.toStringAsFixed(0));
      requestFare();
    } else {
      // Deterministic fallback for custom place names typed by the user
      final str = '${pickup.trim().toLowerCase()}->${dropoff.trim().toLowerCase()}';
      final hash = str.codeUnits.fold<int>(0, (prev, element) => prev + element);
      final rand = math.Random(hash);
      
      // distance between 2.5 and 35.0 km
      double dist = 2.5 + rand.nextDouble() * 32.5;
      // duration between 1.5 and 2.5 minutes per km, plus 4 mins traffic buffer
      double dur = dist * (1.5 + rand.nextDouble() * 1.0) + 4.0;
      
      distanceKm = double.parse(dist.toStringAsFixed(1));
      durationMin = double.parse(dur.toStringAsFixed(0));
      requestFare();
    }
  }

  static const _rateCard = {
    'auto':  {'base': 25.0, 'per_km': 11.0, 'per_min': 1.2},
    'bike':  {'base': 15.0, 'per_km': 7.0,  'per_min': 0.8},
    'mini':  {'base': 40.0, 'per_km': 14.0, 'per_min': 1.5},
    'sedan': {'base': 60.0, 'per_km': 18.0, 'per_min': 2.0},
  };

  Map<String, double> get currentRates =>
      Map<String, double>.from(_rateCard[vehicleType] ?? _rateCard['sedan']!);

  FareProvider() {
    _ws.connect();
    _ws.fareStream.listen((f) {
      fare = f;
      isLoading = false;
      isConnected = true;
      notifyListeners();
    });
    // Send initial request
    Future.delayed(const Duration(milliseconds: 500), requestFare);
  }

  void updateDistance(double v) {
    distanceKm = v;
    requestFare();
    notifyListeners();
  }

  void updateDistanceString(String s) {
    final v = double.tryParse(s);
    if (v != null && v > 0) {
      distanceKm = v;
      requestFare();
      notifyListeners();
    }
  }

  void updateDuration(double v) {
    durationMin = v;
    requestFare();
    notifyListeners();
  }

  void updateDurationString(String s) {
    final v = double.tryParse(s);
    if (v != null && v > 0) {
      durationMin = v;
      requestFare();
      notifyListeners();
    }
  }

  void updateVehicle(String v) {
    vehicleType = v;
    requestFare();
    notifyListeners();
  }

  void updatePickup(String v) {
    pickup = v;
    notifyListeners();
  }

  void updateDropoff(String v) {
    dropoff = v;
    notifyListeners();
  }

  void requestFare() {
    isLoading = true;
    notifyListeners();
    _ws.sendRequest({
      'distance_km':  distanceKm,
      'duration_min': durationMin,
      'vehicle_type': vehicleType,
      'demand_index': demandIndex,
    });
  }

  // ─── REST API Integrations ──────────────────────────────────────────────────

  Future<FareBreakdown?> calculateFareREST({
    required double distanceKm,
    required double durationMin,
    required String vehicleType,
    double demandIndex = 1.0,
    String? driverId,
    bool record = false,
  }) async {
    try {
      final uri = Uri.parse('http://localhost:8000/api/fare');
      final payload = {
        'distance_km': distanceKm,
        'duration_min': durationMin,
        'vehicle_type': vehicleType,
        'demand_index': demandIndex,
        'driver_id': driverId,
        'record': record,
      };

      final response = await http.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        return FareBreakdown.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('calculateFareREST error: $e');
    }
    return null;
  }

  Future<FareBreakdown?> getTripByIdREST(String tripId) async {
    try {
      final uri = Uri.parse('http://localhost:8000/api/audit/$tripId');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // Recompute the breakdown values for UI display, keeping the database total/hash
        final vType = json['vehicle_type'] as String? ?? 'sedan';
        final rates = _rateCard[vType] ?? _rateCard['sedan']!;
        final dist = (json['distance_km'] as num).toDouble();
        final dur = (json['duration_min'] as num).toDouble();
        final total = (json['total_fare'] as num).toDouble();

        final base = rates['base']!;
        final distChg = dist * rates['per_km']!;
        final timeChg = dur * rates['per_min']!;
        final platformFee = total * 0.12;
        final gst = total * 0.05;
        final insurance = total * 0.01;
        final driverNet = (json['driver_net'] as num?)?.toDouble() ?? (total - platformFee - gst - insurance);

        final mapped = {
          'trip_id': json['trip_id'],
          'distance_km': dist,
          'duration_min': dur,
          'vehicle_type': vType,
          'total': total,
          'driver_net': driverNet,
          'band_min': (json['fare_band'] as List)[0],
          'band_max': (json['fare_band'] as List)[1],
          'rate_card_version': json['rate_card_version'],
          'fare_hash': json['fare_hash'],
          'base': base,
          'dist_charge': distChg,
          'time_charge': timeChg,
          'fuel_charge': total - base - distChg - timeChg, // back-calculate
          'platform_fee': platformFee,
          'gst': gst,
          'insurance': insurance,
        };
        return FareBreakdown.fromJson(mapped);
      }
    } catch (e) {
      debugPrint('getTripByIdREST error: $e');
    }
    return null;
  }

  Future<FareBreakdown?> getLatestTripREST() async {
    try {
      final uri = Uri.parse('http://localhost:8000/api/latest-trip');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return FareBreakdown.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('getLatestTripREST error: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _ws.dispose();
    super.dispose();
  }
}

class RegulatorProvider extends ChangeNotifier {
  // RegulatorProvider managed regulator state.
}