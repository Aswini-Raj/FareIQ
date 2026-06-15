"""
rate_card.py
Single source of truth for fare calculation constants.
Bump RATE_CARD_VERSION whenever any number below changes — the version
string is embedded in every fare hash, so passengers, drivers, and
regulators can all verify which rules were applied to a given trip.
"""

RATE_CARD_VERSION = "v2.3.1-2026-06"

# Per-vehicle pricing
VEHICLE_RATES = {
    "auto":  {"base": 25.0, "per_km": 11.0, "per_min": 1.2, "mileage_km_per_l": 35.0},
    "bike":  {"base": 15.0, "per_km": 7.0,  "per_min": 0.8, "mileage_km_per_l": 45.0},
    "mini":  {"base": 40.0, "per_km": 14.0, "per_min": 1.5, "mileage_km_per_l": 16.0},
    "sedan": {"base": 60.0, "per_km": 18.0, "per_min": 2.0, "mileage_km_per_l": 14.0},
}

# CMTA-approved fare band tolerance (± this fraction of the computed fare)
FARE_BAND_TOLERANCE = 0.08  # 8%

# Demand multiplier is informational only — FareIQ never charges above 1.0x
MAX_DEMAND_MULTIPLIER = 1.0

# Driver-side deductions (fractions of gross fare)
PLATFORM_FEE_PCT = 0.12
GST_PCT          = 0.05
INSURANCE_PCT    = 0.01


def vehicle_rate(vehicle_type: str) -> dict:
    return VEHICLE_RATES.get(vehicle_type, VEHICLE_RATES["sedan"])