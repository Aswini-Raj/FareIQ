"""
models.py
Pydantic schemas shared across WebSocket and REST endpoints.
Field names use snake_case to match Flutter's FareBreakdown.fromJson
and RegulatorProvider parsers exactly.
"""

from pydantic import BaseModel, Field
from typing import Optional, Literal


class FareRequest(BaseModel):
    distance_km: float = Field(..., gt=0, le=200)
    duration_min: float = Field(..., gt=0, le=240)
    vehicle_type: Literal["auto", "bike", "mini", "sedan"] = "sedan"
    demand_index: float = Field(1.0, ge=0)
    driver_id: Optional[str] = None
    record: Optional[bool] = False


class FareResponse(BaseModel):
    trip_id: str
    base: float
    dist_charge: float
    time_charge: float
    fuel_charge: float
    total: float
    band_min: float
    band_max: float
    platform_fee: float
    gst: float
    insurance: float
    driver_net: float
    fare_hash: str
    rate_card_version: str


class VerifyResult(BaseModel):
    type: Literal["verify_result"] = "verify_result"
    status: Literal["VERIFIED", "FLAGGED", "NOT_FOUND"]
    trip_id: str