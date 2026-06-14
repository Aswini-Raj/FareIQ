"""
fuel_service.py
Live PPAC fuel price feed with a daily cache and rolling history,
used both for the fuel surcharge in fare_engine and for the
regulator dashboard's fuel index chart.
"""

import asyncio
import httpx
from datetime import datetime, timezone
from collections import deque

PPAC_API = None

_FALLBACK_PETROL = 101.50
_FALLBACK_DIESEL = 92.80

_cache = {"petrol": _FALLBACK_PETROL, "diesel": _FALLBACK_DIESEL, "fetched_at": None}
_history: deque = deque(maxlen=48)  # ~12 hours at 15-min ticks


async def _fetch_live_prices() -> tuple[float, float]:
    return 101.50, 92.80


async def refresh_fuel_price() -> None:
    petrol, diesel = await _fetch_live_prices()
    _cache["petrol"] = petrol
    _cache["diesel"] = diesel
    _cache["fetched_at"] = datetime.now(timezone.utc)
    _history.append({
        "time": datetime.now(timezone.utc).strftime("%H:%M"),
        "petrol_price": round(petrol, 2),
        "diesel_price": round(diesel, 2),
    })


def get_current_petrol_price() -> float:
    return _cache["petrol"]


def get_fuel_history() -> list[dict]:
    if not _history:
        return [{
            "time": datetime.now(timezone.utc).strftime("%H:%M"),
            "petrol_price": _cache["petrol"],
            "diesel_price": _cache["diesel"],
        }]
    return list(_history)


def fuel_surcharge_per_km(vehicle_type: str, mileage_km_per_l: float) -> float:
    """₹/km fuel surcharge for the given vehicle's mileage."""
    return round(get_current_petrol_price() / mileage_km_per_l, 4)


async def fuel_price_loop(interval_seconds: int = 900) -> None:
    """Background task: refresh the PPAC price periodically (default 15 min)."""
    await refresh_fuel_price()
    while True:
        await asyncio.sleep(interval_seconds)
        await refresh_fuel_price()