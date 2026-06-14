"""
anomaly_detector.py
Recomputes each trip's fare hash from its stored inputs and flags any
mismatch — the same check the regulator's "Audit Hash Verifier" widget
calls over WebSocket.
"""

import hashlib
from sqlalchemy import select, insert
from database import engine, audit_log, anomaly_flags
from audit_ledger import get_trip


def _recompute_hash(row: dict) -> str:
    return hashlib.sha256(
        f"{row['distance_km']}|{row['duration_min']}|{row['vehicle_type']}|"
        f"{row['total_fare']}|{row['rate_card_version']}|{row['ts_epoch']}".encode()
    ).hexdigest()


def verify_trip_hash(trip_id: str) -> dict:
    row = get_trip(trip_id)
    if row is None:
        return {"status": "NOT_FOUND", "trip_id": trip_id}

    recomputed = _recompute_hash(row)
    if recomputed != row["fare_hash"]:
        flag_anomaly(trip_id, reason="hash_mismatch", severity="high")
        return {"status": "FLAGGED", "trip_id": trip_id}

    if not (row["band_min"] <= row["total_fare"] <= row["band_max"]):
        flag_anomaly(trip_id, reason="band_violation", severity="medium")
        return {"status": "FLAGGED", "trip_id": trip_id}

    return {"status": "VERIFIED", "trip_id": trip_id}


def flag_anomaly(trip_id: str, reason: str, severity: str = "medium") -> None:
    with engine.begin() as conn:
        conn.execute(insert(anomaly_flags).values(
            trip_id=trip_id, reason=reason, severity=severity,
        ))


def list_open_anomalies(limit: int = 20) -> list[dict]:
    with engine.connect() as conn:
        rows = conn.execute(
            select(anomaly_flags, audit_log)
            .join(audit_log, audit_log.c.trip_id == anomaly_flags.c.trip_id)
            .order_by(anomaly_flags.c.created_at.desc())
            .limit(limit)
        ).mappings().all()

    alerts = []
    for r in rows:
        alerts.append({
            "trip_id": r["trip_id"],
            "reason": r["reason"],
            "severity": r["severity"],
            "vehicle": r["vehicle_type"],
            "fare_amount": r["total_fare"],
            "expected_range": [r["band_min"], r["band_max"]],
            "timestamp": (r["created_at"].isoformat() + "Z") if r["created_at"] else None,
            "driver_id": r["driver_id"] or "—",
        })
    return alerts