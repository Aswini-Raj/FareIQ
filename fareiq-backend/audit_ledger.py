"""
audit_ledger.py
Append-only audit trail. Every computed fare is written here so it can
later be re-verified by anomaly_detector.verify_trip_hash and surfaced
on the regulator dashboard's QR / hash lookup.
"""

from sqlalchemy import select, func
from database import engine, audit_log


def record_trip(fare: dict, driver_id: str | None = None) -> None:
    with engine.begin() as conn:
        conn.execute(audit_log.insert().values(
            trip_id=fare["trip_id"],
            distance_km=fare["distance_km"],
            duration_min=fare["duration_min"],
            vehicle_type=fare["vehicle_type"],
            total_fare=fare["total"],
            driver_net=fare["driver_net"],
            band_min=fare["band_min"],
            band_max=fare["band_max"],
            rate_card_version=fare["rate_card_version"],
            fare_hash=fare["fare_hash"],
            driver_id=driver_id,
            ts_epoch=fare["ts_epoch"],
        ))


def get_trip(trip_id: str) -> dict | None:
    with engine.connect() as conn:
        row = conn.execute(
            select(audit_log).where(audit_log.c.trip_id == trip_id)
        ).mappings().first()
    return dict(row) if row else None


def trips_today_count() -> int:
    with engine.connect() as conn:
        return conn.execute(select(func.count()).select_from(audit_log)).scalar() or 0


def average_fare() -> float:
    with engine.connect() as conn:
        avg = conn.execute(select(func.avg(audit_log.c.total_fare))).scalar()
    return round(avg, 2) if avg else 0.0


def total_revenue() -> float:
    with engine.connect() as conn:
        total = conn.execute(select(func.sum(audit_log.c.total_fare))).scalar()
    return round(total, 2) if total else 0.0


def compliance_by_vehicle() -> list[dict]:
    """% of recorded trips whose total fare fell within its own band."""
    with engine.connect() as conn:
        rows = conn.execute(select(audit_log)).mappings().all()

    buckets: dict[str, list[bool]] = {}
    for r in rows:
        within = r["band_min"] <= r["total_fare"] <= r["band_max"]
        buckets.setdefault(r["vehicle_type"], []).append(within)

    result = []
    for vehicle, flags in buckets.items():
        pct = round(100 * sum(flags) / len(flags), 1) if flags else 100.0
        result.append({
            "vehicle": vehicle,
            "within_band_pct": pct,
            "total_trips": len(flags),
        })
    return result