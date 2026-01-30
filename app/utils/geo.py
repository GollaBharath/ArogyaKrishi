"""
Geographic utilities for ArogyaKrishi.

This module implements the Haversine formula to compute great-circle
distance between two latitude/longitude points on Earth.
"""
from __future__ import annotations

import math


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Return the great-circle distance between two points in kilometers.

    Uses the Haversine formula with Earth radius fixed to 6371 km.

    Args:
        lat1: Latitude of the first point in decimal degrees.
        lon1: Longitude of the first point in decimal degrees.
        lat2: Latitude of the second point in decimal degrees.
        lon2: Longitude of the second point in decimal degrees.

    Returns:
        Distance between the two points in kilometers as a float.
    """

    # Convert decimal degrees to radians for all coordinates
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)

    # Differences in coordinates
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    # Haversine formula components
    # a = sin^2(dlat/2) + cos(lat1) * cos(lat2) * sin^2(dlon/2)
    a = (math.sin(dlat / 2) ** 2
         + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2) ** 2)

    # c = 2 * atan2(sqrt(a), sqrt(1-a)) -> central angle in radians
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Earth radius in kilometers (specified constraint)
    R = 6371.0

    # Distance = R * c
    distance_km = R * c

    return distance_km
