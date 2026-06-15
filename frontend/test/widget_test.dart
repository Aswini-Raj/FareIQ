import 'package:flutter_test/flutter_test.dart';
import 'package:fareiq/models/fare_model.dart';

void main() {
  group('FareBreakdown Model Tests', () {
    test('should parse valid json correctly', () {
      final json = {
        'base': 60.0,
        'dist_charge': 334.8,
        'time_charge': 72.0,
        'fuel_charge': 12.5,
        'total': 479.3,
        'band_min': 450.0,
        'band_max': 520.0,
        'platform_fee': 15.0,
        'gst': 22.5,
        'insurance': 2.0,
        'driver_net': 400.0,
        'fare_hash': 'abc123sha256hash',
        'rate_card_version': 'v1.2',
      };

      final fare = FareBreakdown.fromJson(json);

      expect(fare.base, 60.0);
      expect(fare.distCharge, 334.8);
      expect(fare.timeCharge, 72.0);
      expect(fare.fuelCharge, 12.5);
      expect(fare.total, 479.3);
      expect(fare.bandMin, 450.0);
      expect(fare.bandMax, 520.0);
      expect(fare.platformFee, 15.0);
      expect(fare.gst, 22.5);
      expect(fare.insurance, 2.0);
      expect(fare.driverNet, 400.0);
      expect(fare.fareHash, 'abc123sha256hash');
      expect(fare.rateCardVersion, 'v1.2');
      expect(fare.withinBand, true);
    });

    test('should identify fare outside of band', () {
      final json = {
        'base': 60.0,
        'dist_charge': 334.8,
        'time_charge': 72.0,
        'fuel_charge': 12.5,
        'total': 600.0, // outside max
        'band_min': 450.0,
        'band_max': 520.0,
        'platform_fee': 15.0,
        'gst': 22.5,
        'insurance': 2.0,
        'driver_net': 400.0,
        'fare_hash': 'abc123sha256hash',
        'rate_card_version': 'v1.2',
      };

      final fare = FareBreakdown.fromJson(json);
      expect(fare.withinBand, false);
    });
  });
}
