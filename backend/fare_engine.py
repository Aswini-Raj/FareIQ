"""
fare_engine.py
Deterministic, auditable fare computation.

Given identical inputs (distance, duration, vehicle, rate card version,
fuel price, timestamp) this ALWAYS produces the same total and the same
fare_hash — that determinism is exactly what anomaly_detector verifies.
"""

import hashlib
import time
import uuid

from rate_card import (
    RATE_CARD_VERSION, vehicle_rate, FARE_BAND_TOLERANCE,
    MAX_DEMAND_MULTIPLIER, PLATFORM_FEE_PCT, GST_PCT, INSURANCE_PCT,
)
from fuel_service import fuel_surcharge_per_km


def compute_fare(
    distance_km: float,
    duration_min: float,
    vehicle_type: str,
    demand_index: float = 1.0,
) -> dict:
    rates = vehicle_rate(vehicle_type)

    # Demand is informational only — never multiplies the fare.
    demand_index = min(max(demand_index, 0.0), MAX_DEMAND_MULTIPLIER)

    base = rates["base"]
    dist_charge = round(distance_km * rates["per_km"], 2)
    time_charge = round(duration_min * rates["per_min"], 2)

    fuel_rate_per_km = fuel_surcharge_per_km(vehicle_type, rates["mileage_km_per_l"])
    fuel_charge = round(distance_km * fuel_rate_per_km, 2)

    total = round(base + dist_charge + time_charge + fuel_charge, 2)

    band_min = round(total * (1 - FARE_BAND_TOLERANCE), 2)
    band_max = round(total * (1 + FARE_BAND_TOLERANCE), 2)

    platform_fee = round(total * PLATFORM_FEE_PCT, 2)
    gst          = round(total * GST_PCT, 2)
    insurance    = round(total * INSURANCE_PCT, 2)
    driver_net   = round(total - platform_fee - gst - insurance, 2)

    ts_epoch = int(time.time())
    trip_id = f"TRP{uuid.uuid4().hex[:8].upper()}"

    fare_hash = hashlib.sha256(
        f"{distance_km}|{duration_min}|{vehicle_type}|{total}|"
        f"{RATE_CARD_VERSION}|{ts_epoch}".encode()
    ).hexdigest()

    return {
        "trip_id": trip_id,
        "base": base,
        "dist_charge": dist_charge,
        "time_charge": time_charge,
        "fuel_charge": fuel_charge,
        "total": total,
        "band_min": band_min,
        "band_max": band_max,
        "platform_fee": platform_fee,
        "gst": gst,
        "insurance": insurance,
        "driver_net": driver_net,
        "fare_hash": fare_hash,
        "rate_card_version": RATE_CARD_VERSION,
        # internal fields used by audit_ledger / anomaly_detector
        "distance_km": distance_km,
        "duration_min": duration_min,
        "vehicle_type": vehicle_type,
        "ts_epoch": ts_epoch,
        "demand_index": demand_index,
    }