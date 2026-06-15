"""
database.py
Lightweight storage layer for the audit ledger.

Defaults to a local SQLite file (audit.db) so the whole backend runs
with zero external services. Set DATABASE_URL to a Postgres/Supabase
connection string in production — the same SQL works on both via
SQLAlchemy Core.
"""

import os
from datetime import datetime
from sqlalchemy import (
    create_engine, MetaData, Table, Column, String, Float, Integer, DateTime
)

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///audit.db")

connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(DATABASE_URL, connect_args=connect_args, future=True)
metadata = MetaData()

audit_log = Table(
    "audit_log", metadata,
    Column("trip_id", String, primary_key=True),
    Column("distance_km", Float, nullable=False),
    Column("duration_min", Float, nullable=False),
    Column("vehicle_type", String, nullable=False),
    Column("total_fare", Float, nullable=False),
    Column("driver_net", Float, nullable=False),
    Column("band_min", Float, nullable=False),
    Column("band_max", Float, nullable=False),
    Column("rate_card_version", String, nullable=False),
    Column("fare_hash", String, nullable=False),
    Column("driver_id", String, nullable=True),
    Column("ts_epoch", Integer, nullable=False),
    Column("created_at", DateTime, default=datetime.utcnow),
)

anomaly_flags = Table(
    "anomaly_flags", metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("trip_id", String, nullable=False),
    Column("reason", String, nullable=False),
    Column("severity", String, nullable=False),
    Column("created_at", DateTime, default=datetime.utcnow),
)


def init_db() -> None:
    metadata.create_all(engine)