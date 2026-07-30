"""
BirdSense AI — Algorithme de Floutage GPS (5 km)
Auteur : Pape Alioune Sène

Algorithme de protection des espèces menacées (IUCN EN/CR) :
- Décalage aléatoire dans un anneau [min_radius, max_radius]
- Utilisé UNIQUEMENT pour les espèces marquées is_protected=True
- Les coordonnées réelles restent stockées et jamais exposées via l'API publique
"""
import math
import random

from app.config import get_settings

settings = get_settings()

# Rayon de la Terre en mètres (WGS84 equatorial)
EARTH_RADIUS_M = 6_378_137.0

# Les espèces IUCN EN et CR déclenchent le floutage
PROTECTED_IUCN_STATUSES = frozenset({"EN", "CR"})


def _meters_to_degrees_lat(meters: float) -> float:
    """Convertit une distance en mètres en degrés de latitude."""
    return meters / 111_320.0


def _meters_to_degrees_lon(meters: float, latitude_deg: float) -> float:
    """Convertit une distance en mètres en degrés de longitude à une latitude donnée."""
    return meters / (111_320.0 * math.cos(math.radians(latitude_deg)))


def blur_coordinates(
    latitude: float,
    longitude: float,
    radius_m: float | None = None,
    min_radius_m: float = 2000.0,
) -> tuple[float, float]:
    """
    Applique un décalage GPS aléatoire dans un anneau [min_radius_m, radius_m].

    L'anneau (au lieu d'un disque complet) garantit que les coordonnées floutées
    ne peuvent jamais coïncider avec le point original, empêchant ainsi la
    triangulation par des observations multiples.

    Args:
        latitude: Latitude réelle en degrés décimaux WGS84.
        longitude: Longitude réelle en degrés décimaux WGS84.
        radius_m: Rayon maximal du floutage en mètres (défaut : GPS_BLUR_RADIUS_METERS).
        min_radius_m: Rayon minimal du floutage en mètres (défaut : 2 km).

    Returns:
        (blurred_latitude, blurred_longitude) : Tuple de coordonnées floutées.
    """
    if radius_m is None:
        radius_m = settings.gps_blur_radius_meters

    # Distance de décalage aléatoire dans l'anneau [min, max]
    distance_m = random.uniform(min_radius_m, radius_m)

    # Direction aléatoire (angle en radians)
    angle_rad = random.uniform(0, 2 * math.pi)

    # Calcul du décalage en degrés selon la direction
    delta_lat = _meters_to_degrees_lat(distance_m) * math.cos(angle_rad)
    delta_lon = _meters_to_degrees_lon(distance_m, latitude) * math.sin(angle_rad)

    blurred_lat = latitude + delta_lat
    blurred_lon = longitude + delta_lon

    # Clamp des valeurs pour rester dans les bornes valides WGS84
    blurred_lat = max(-90.0, min(90.0, blurred_lat))
    blurred_lon = max(-180.0, min(180.0, blurred_lon))

    return blurred_lat, blurred_lon


def should_blur(iucn_status: str | None, is_protected: bool) -> bool:
    """
    Détermine si le floutage GPS doit être appliqué.

    Args:
        iucn_status: Statut IUCN de l'espèce (LC, NT, VU, EN, CR, EW, EX).
        is_protected: Flag is_protected du modèle Species.

    Returns:
        True si les coordonnées doivent être floutées.
    """
    if is_protected:
        return True
    if iucn_status and iucn_status.upper() in PROTECTED_IUCN_STATUSES:
        return True
    return False


def compute_distance_m(
    lat1: float, lon1: float, lat2: float, lon2: float
) -> float:
    """
    Calcule la distance orthodromique (Haversine) entre deux points GPS en mètres.
    Utilisé pour la validation des Bounding Box et des filtres de proximité.

    Args:
        lat1, lon1: Coordonnées du point 1.
        lat2, lon2: Coordonnées du point 2.

    Returns:
        Distance en mètres.
    """
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)

    a = (
        math.sin(dphi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return EARTH_RADIUS_M * c


def build_wkt_point(latitude: float, longitude: float) -> str:
    """
    Génère une chaîne WKT POINT compatible PostGIS.
    Format : 'POINT(longitude latitude)' — note l'ordre lon/lat pour WGS84.
    """
    return f"SRID=4326;POINT({longitude} {latitude})"
