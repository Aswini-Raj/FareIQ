"""
regulator_service.py
Builds the periodic snapshot broadcast to /ws/regulator:
  - compliance stats
  - fuel index history
  - fare-band compliance by vehicle
  - open anomalies
  - driver trust leaderboard

Trust scores are seeded demo data with a small live jitter so the
leaderboard visibly updates — wire this to real driver telemetry
(on-time %, cancellation %) once available.
"""

import random

from rate_card import RATE_CARD_VERSION
from fuel_service import get_fuel_history
from audit_ledger import trips_today_count, average_fare, total_revenue, compliance_by_vehicle
from anomaly_detector import list_open_anomalies

_DRIVER_SEED = [
    {"driver_id": "DRV-1042", "name": "R. Kumar",   "on_time_pct": 96.5, "cancellation_pct": 1.2, "total_trips": 1024},
    {"driver_id": "DRV-2031", "name": "S. Priya",   "on_time_pct": 94.1, "cancellation_pct": 2.0, "total_trips": 871},
    {"driver_id": "DRV-3110", "name": "M. Arul",    "on_time_pct": 91.8, "cancellation_pct": 3.4, "total_trips": 632},
    {"driver_id": "DRV-4087", "name": "K. Devi",    "on_time_pct": 88.2, "cancellation_pct": 4.9, "total_trips": 540},
    {"driver_id": "DRV-5023", "name": "T. Suresh",  "on_time_pct": 99.0, "cancellation_pct": 0.5, "total_trips": 1300},
    {"driver_id": "DRV-6018", "name": "N. Lakshmi", "on_time_pct": 85.0, "cancellation_pct": 6.1, "total_trips": 410},
]


def _trust_score(on_time_pct: float, cancellation_pct: float) -> float:
    score = 0.7 * on_time_pct + 0.3 * (100 - cancellation_pct * 5)
    return round(max(0.0, min(100.0, score)), 1)


def driver_trust_scores() -> list[dict]:
    out = []
    for d in _DRIVER_SEED:
        jitter = random.uniform(-0.3, 0.3)
        on_time = max(0.0, min(100.0, d["on_time_pct"] + jitter))
        cancellation = max(0.0, d["cancellation_pct"] - jitter / 2)
        out.append({
            "driver_id": d["driver_id"],
            "name": d["name"],
            "on_time_pct": round(on_time, 1),
            "cancellation_pct": round(cancellation, 1),
            "trust_score": _trust_score(on_time, cancellation),
            "total_trips": d["total_trips"],
        })
    return sorted(out, key=lambda x: x["trust_score"], reverse=True)


def build_snapshot() -> dict:
    anomalies = list_open_anomalies()
    compliance = compliance_by_vehicle()
    overall_compliance = (
        round(sum(c["within_band_pct"] * c["total_trips"] for c in compliance) /
              sum(c["total_trips"] for c in compliance), 1)
        if compliance else 100.0
    )

    return {
        "stats": {
            "active_trips": random.randint(80, 180),  # swap for live session count
            "verified_today": trips_today_count(),
            "anomalies_flagged": len(anomalies),
            "compliance_rate": overall_compliance,
            "avg_fare": average_fare(),
            "total_revenue_today": total_revenue(),
        },
        "fuel_history": get_fuel_history(),
        "compliance_by_vehicle": compliance,
        "anomalies": anomalies,
        "trust_scores": driver_trust_scores(),
        "rate_card_version": RATE_CARD_VERSION,
    }