class FareBreakdown {
  final String tripId;
  final double base;
  final double distCharge;
  final double timeCharge;
  final double fuelCharge;
  final double total;
  final double bandMin;
  final double bandMax;
  final double platformFee;
  final double gst;
  final double insurance;
  final double driverNet;
  final String fareHash;
  final String rateCardVersion;
  final bool withinBand;
  final double distanceKm;
  final double durationMin;
  final String vehicleType;
  final int tsEpoch;

  const FareBreakdown({
    required this.tripId,
    required this.base,
    required this.distCharge,
    required this.timeCharge,
    required this.fuelCharge,
    required this.total,
    required this.bandMin,
    required this.bandMax,
    required this.platformFee,
    required this.gst,
    required this.insurance,
    required this.driverNet,
    required this.fareHash,
    required this.rateCardVersion,
    required this.withinBand,
    required this.distanceKm,
    required this.durationMin,
    required this.vehicleType,
    required this.tsEpoch,
  });

  factory FareBreakdown.fromJson(Map<String, dynamic> j) {
    final total = (j['total'] as num).toDouble();
    final bandMin = (j['band_min'] as num).toDouble();
    final bandMax = (j['band_max'] as num).toDouble();
    return FareBreakdown(
      tripId: j['trip_id'] as String? ?? '',
      base: (j['base'] as num).toDouble(),
      distCharge: (j['dist_charge'] as num).toDouble(),
      timeCharge: (j['time_charge'] as num).toDouble(),
      fuelCharge: (j['fuel_charge'] as num).toDouble(),
      total: total,
      bandMin: bandMin,
      bandMax: bandMax,
      platformFee: (j['platform_fee'] as num).toDouble(),
      gst: (j['gst'] as num).toDouble(),
      insurance: (j['insurance'] as num).toDouble(),
      driverNet: (j['driver_net'] as num).toDouble(),
      fareHash: j['fare_hash'] as String? ?? '',
      rateCardVersion: j['rate_card_version'] as String? ?? '',
      withinBand: total >= bandMin && total <= bandMax,
      distanceKm: (j['distance_km'] as num?)?.toDouble() ?? 0.0,
      durationMin: (j['duration_min'] as num?)?.toDouble() ?? 0.0,
      vehicleType: j['vehicle_type'] as String? ?? 'sedan',
      tsEpoch: (j['ts_epoch'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChennaiRouteMatrix {
  static const List<String> places = [
    'T. Nagar, Chennai',
    'OMR, Sholinganallur',
    'Central Station, Chennai',
    'Chennai Airport',
    'Guindy, Chennai',
    'Adyar, Chennai',
    'Mylapore, Chennai',
    'Marina Beach, Chennai',
    'Anna Nagar, Chennai',
    'Velachery, Chennai'
  ];

  static final Map<String, Map<String, ChennaiRouteData>> _matrix = {
    'T. Nagar, Chennai': {
      'OMR, Sholinganallur': const ChennaiRouteData(18.6, 36),
      'Central Station, Chennai': const ChennaiRouteData(7.5, 18),
      'Chennai Airport': const ChennaiRouteData(12.8, 30),
      'Guindy, Chennai': const ChennaiRouteData(5.4, 12),
      'Adyar, Chennai': const ChennaiRouteData(8.0, 20),
      'Mylapore, Chennai': const ChennaiRouteData(4.8, 14),
      'Marina Beach, Chennai': const ChennaiRouteData(6.5, 16),
      'Anna Nagar, Chennai': const ChennaiRouteData(8.5, 20),
      'Velachery, Chennai': const ChennaiRouteData(10.2, 24),
    },
    'OMR, Sholinganallur': {
      'T. Nagar, Chennai': const ChennaiRouteData(18.6, 36),
      'Central Station, Chennai': const ChennaiRouteData(24.5, 55),
      'Chennai Airport': const ChennaiRouteData(16.5, 38),
      'Guindy, Chennai': const ChennaiRouteData(14.0, 32),
      'Adyar, Chennai': const ChennaiRouteData(12.2, 28),
      'Mylapore, Chennai': const ChennaiRouteData(17.5, 40),
      'Marina Beach, Chennai': const ChennaiRouteData(19.0, 42),
      'Anna Nagar, Chennai': const ChennaiRouteData(26.0, 60),
      'Velachery, Chennai': const ChennaiRouteData(9.8, 22),
    },
    'Central Station, Chennai': {
      'T. Nagar, Chennai': const ChennaiRouteData(7.5, 18),
      'OMR, Sholinganallur': const ChennaiRouteData(24.5, 55),
      'Chennai Airport': const ChennaiRouteData(21.0, 45),
      'Guindy, Chennai': const ChennaiRouteData(11.8, 26),
      'Adyar, Chennai': const ChennaiRouteData(12.5, 28),
      'Mylapore, Chennai': const ChennaiRouteData(6.2, 15),
      'Marina Beach, Chennai': const ChennaiRouteData(3.5, 10),
      'Anna Nagar, Chennai': const ChennaiRouteData(9.0, 22),
      'Velachery, Chennai': const ChennaiRouteData(15.5, 36),
    },
    'Chennai Airport': {
      'T. Nagar, Chennai': const ChennaiRouteData(12.8, 30),
      'OMR, Sholinganallur': const ChennaiRouteData(16.5, 38),
      'Central Station, Chennai': const ChennaiRouteData(21.0, 45),
      'Guindy, Chennai': const ChennaiRouteData(7.5, 18),
      'Adyar, Chennai': const ChennaiRouteData(13.2, 28),
      'Mylapore, Chennai': const ChennaiRouteData(15.8, 34),
      'Marina Beach, Chennai': const ChennaiRouteData(18.2, 38),
      'Anna Nagar, Chennai': const ChennaiRouteData(17.0, 35),
      'Velachery, Chennai': const ChennaiRouteData(11.2, 24),
    },
    'Guindy, Chennai': {
      'T. Nagar, Chennai': const ChennaiRouteData(5.4, 12),
      'OMR, Sholinganallur': const ChennaiRouteData(14.0, 32),
      'Central Station, Chennai': const ChennaiRouteData(11.8, 26),
      'Chennai Airport': const ChennaiRouteData(7.5, 18),
      'Adyar, Chennai': const ChennaiRouteData(5.8, 14),
      'Mylapore, Chennai': const ChennaiRouteData(9.2, 20),
      'Marina Beach, Chennai': const ChennaiRouteData(11.5, 24),
      'Anna Nagar, Chennai': const ChennaiRouteData(11.0, 24),
      'Velachery, Chennai': const ChennaiRouteData(6.5, 15),
    },
    'Adyar, Chennai': {
      'T. Nagar, Chennai': const ChennaiRouteData(8.0, 20),
      'OMR, Sholinganallur': const ChennaiRouteData(12.2, 28),
      'Central Station, Chennai': const ChennaiRouteData(12.5, 28),
      'Chennai Airport': const ChennaiRouteData(13.2, 28),
      'Guindy, Chennai': const ChennaiRouteData(5.8, 14),
      'Mylapore, Chennai': const ChennaiRouteData(4.2, 11),
      'Marina Beach, Chennai': const ChennaiRouteData(6.0, 14),
      'Anna Nagar, Chennai': const ChennaiRouteData(14.5, 32),
      'Velachery, Chennai': const ChennaiRouteData(7.2, 16),
    },
    'Mylapore, Chennai': {
      'T. Nagar, Chennai': const ChennaiRouteData(4.8, 14),
      'OMR, Sholinganallur': const ChennaiRouteData(17.5, 40),
      'Central Station, Chennai': const ChennaiRouteData(6.2, 15),
      'Chennai Airport': const ChennaiRouteData(15.8, 34),
      'Guindy, Chennai': const ChennaiRouteData(9.2, 20),
      'Adyar, Chennai': const ChennaiRouteData(4.2, 11),
      'Marina Beach, Chennai': const ChennaiRouteData(2.8, 8),
      'Anna Nagar, Chennai': const ChennaiRouteData(11.5, 25),
      'Velachery, Chennai': const ChennaiRouteData(11.0, 24),
    },
    'Marina Beach, Chennai': {
      'T. Nagar, Chennai': const ChennaiRouteData(6.5, 16),
      'OMR, Sholinganallur': const ChennaiRouteData(19.0, 42),
      'Central Station, Chennai': const ChennaiRouteData(3.5, 10),
      'Chennai Airport': const ChennaiRouteData(18.2, 38),
      'Guindy, Chennai': const ChennaiRouteData(11.5, 24),
      'Adyar, Chennai': const ChennaiRouteData(6.0, 14),
      'Mylapore, Chennai': const ChennaiRouteData(2.8, 8),
      'Anna Nagar, Chennai': const ChennaiRouteData(12.0, 26),
      'Velachery, Chennai': const ChennaiRouteData(13.2, 28),
    },
    'Anna Nagar, Chennai': {
      'T. Nagar, Chennai': const ChennaiRouteData(8.5, 20),
      'OMR, Sholinganallur': const ChennaiRouteData(26.0, 60),
      'Central Station, Chennai': const ChennaiRouteData(9.0, 22),
      'Chennai Airport': const ChennaiRouteData(17.0, 35),
      'Guindy, Chennai': const ChennaiRouteData(11.0, 24),
      'Adyar, Chennai': const ChennaiRouteData(14.5, 32),
      'Mylapore, Chennai': const ChennaiRouteData(11.5, 25),
      'Marina Beach, Chennai': const ChennaiRouteData(12.0, 26),
      'Velachery, Chennai': const ChennaiRouteData(15.8, 34),
    },
    'Velachery, Chennai': {
      'T. Nagar, Chennai': const ChennaiRouteData(10.2, 24),
      'OMR, Sholinganallur': const ChennaiRouteData(9.8, 22),
      'Central Station, Chennai': const ChennaiRouteData(15.5, 36),
      'Chennai Airport': const ChennaiRouteData(11.2, 24),
      'Guindy, Chennai': const ChennaiRouteData(6.5, 15),
      'Adyar, Chennai': const ChennaiRouteData(7.2, 16),
      'Mylapore, Chennai': const ChennaiRouteData(11.0, 24),
      'Marina Beach, Chennai': const ChennaiRouteData(13.2, 28),
      'Anna Nagar, Chennai': const ChennaiRouteData(15.8, 34),
    },
  };

  static ChennaiRouteData getRoute(String from, String to) {
    if (from == to) return const ChennaiRouteData(0.0, 0);

    final direct = _matrix[from]?[to];
    if (direct != null) return direct;

    final reverse = _matrix[to]?[from];
    if (reverse != null) return reverse;

    // Fallback: estimate based on hash
    final hash = (from.hashCode - to.hashCode).abs();
    final double dist = (hash % 12) + 3.0;
    final int dur = (dist * 2.2).round() + 4;
    return ChennaiRouteData(double.parse(dist.toStringAsFixed(1)), dur);
  }
}

class ChennaiRouteData {
  final double distanceKm;
  final int durationMin;
  const ChennaiRouteData(this.distanceKm, this.durationMin);
}