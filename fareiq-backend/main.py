"""
main.py
FareIQ FastAPI backend — entry point.

Endpoints
---------
GET  /health                  liveness probe
POST /api/fare                one-shot fare quote (REST fallback)
GET  /api/audit/{trip_id}      public audit lookup (QR code target)
WS   /ws/live                 passenger + driver shared live fare feed
WS   /ws/regulator             regulator dashboard live feed + verifier
"""

import asyncio
import json
import logging

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from database import init_db
from models import FareRequest, FareResponse
from fare_engine import compute_fare
from audit_ledger import record_trip, get_trip
from anomaly_detector import verify_trip_hash
from fuel_service import fuel_price_loop
from regulator_service import build_snapshot

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("fareiq")

app = FastAPI(title="FareIQ API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # tighten to your Flutter web origin in production
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── In-memory connection registries ─────────────────────────────────────────
live_connections: set[WebSocket] = set()
regulator_connections: set[WebSocket] = set()

# Shared "current trip" state — every /ws/live client sees the same trip
# (passenger sliders drive it, driver screen mirrors it). For multi-trip
# production use, key this by a trip/session id instead.
current_trip_params = {
    "distance_km": 18.6,
    "duration_min": 36.0,
    "vehicle_type": "sedan",
    "demand_index": 1.0,
}


@app.on_event("startup")
async def on_startup():
    init_db()
    asyncio.create_task(fuel_price_loop())
    asyncio.create_task(_regulator_broadcast_loop())


# ── REST ──────────────────────────────────────────────────────────────────────

@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/api/fare", response_model=FareResponse)
async def get_fare(req: FareRequest):
    fare = compute_fare(req.distance_km, req.duration_min, req.vehicle_type, req.demand_index)
    if req.record:
        record_trip(fare, driver_id=req.driver_id)
    return fare


@app.get("/api/latest-trip", response_model=FareResponse)
async def get_latest_trip_endpoint():
    from audit_ledger import get_latest_trip
    trip = get_latest_trip()
    if trip is None:
        raise HTTPException(status_code=404, detail="No recorded trips yet")
    return trip


@app.get("/api/audit/{trip_id}")
async def audit_lookup(trip_id: str):
    """Public endpoint behind the QR code on every receipt."""
    trip = get_trip(trip_id)
    if trip is None:
        raise HTTPException(status_code=404, detail="Trip not found")
    verdict = verify_trip_hash(trip_id)
    return {
        "trip_id": trip_id,
        "distance_km": trip["distance_km"],
        "duration_min": trip["duration_min"],
        "vehicle_type": trip["vehicle_type"],
        "total_fare": trip["total_fare"],
        "fare_band": [trip["band_min"], trip["band_max"]],
        "rate_card_version": trip["rate_card_version"],
        "fare_hash": trip["fare_hash"],
        "status": verdict["status"],
    }


# ── WebSocket: /ws/live (Passenger + Driver) ───────────────────────────────────

@app.websocket("/ws/live")
async def ws_live(websocket: WebSocket):
    await websocket.accept()
    live_connections.add(websocket)
    try:
        # Send current state immediately on connect
        await websocket.send_text(json.dumps(compute_fare(**current_trip_params)))

        while True:
            raw = await websocket.receive_text()
            try:
                payload = json.loads(raw)
            except json.JSONDecodeError:
                continue

            current_trip_params.update({
                "distance_km":  float(payload.get("distance_km",  current_trip_params["distance_km"])),
                "duration_min": float(payload.get("duration_min", current_trip_params["duration_min"])),
                "vehicle_type": payload.get("vehicle_type",        current_trip_params["vehicle_type"]),
                "demand_index": float(payload.get("demand_index", current_trip_params["demand_index"])),
            })

            await _broadcast_fare(current_trip_params, driver_id=payload.get("driver_id"))

    except WebSocketDisconnect:
        pass
    finally:
        live_connections.discard(websocket)


async def _broadcast_fare(params: dict, driver_id: str | None = None) -> None:
    fare = compute_fare(**params)
    message = json.dumps(fare)
    dead = []
    for conn in live_connections:
        try:
            await conn.send_text(message)
        except Exception:
            dead.append(conn)
    for conn in dead:
        live_connections.discard(conn)


# ── WebSocket: /ws/regulator ────────────────────────────────────────────────────

@app.websocket("/ws/regulator")
async def ws_regulator(websocket: WebSocket):
    await websocket.accept()
    regulator_connections.add(websocket)

    try:
        await websocket.send_text(json.dumps(build_snapshot()))

        while True:
            raw = await websocket.receive_text()
            payload = json.loads(raw)

            if payload.get("action") == "verify":
                trip_id = payload.get("trip_id", "")
                verdict = verify_trip_hash(trip_id)

                await websocket.send_text(json.dumps({
                    "type": "verify_result",
                    "status": verdict["status"],
                    "trip_id": trip_id,
                }))

    except WebSocketDisconnect:
        print("Regulator disconnected")
    finally:
        regulator_connections.discard(websocket)
async def _regulator_broadcast_loop(interval_seconds: int = 10) -> None:
    """Pushes a fresh snapshot to every connected regulator client."""
    while True:
        await asyncio.sleep(interval_seconds)
        if not regulator_connections:
            continue
        snapshot = json.dumps(build_snapshot())
        dead = []
        for conn in regulator_connections:
            try:
                await conn.send_text(snapshot)
            except Exception:
                dead.append(conn)
        for conn in dead:
            regulator_connections.discard(conn)