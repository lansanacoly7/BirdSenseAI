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


def parse_location_string(location: str) -> tuple[float, float] | None:
    """
    Parse une chaîne de localisation stockée localement en SQLite.
    Formats supportés :
      - "lat,lon"  (format SQLite local)
      - "SRID=4326;POINT(lon lat)"  (format WKT PostGIS)

    Returns:
        (latitude, longitude) ou None si le format est inconnu.
    """
    if not location:
        return None
    try:
        # Format WKT PostGIS : SRID=4326;POINT(lon lat)
        if "POINT" in location:
            inner = location.split("POINT(")[1].rstrip(")")
            lon_str, lat_str = inner.split()
            return float(lat_str), float(lon_str)
        # Format SQLite local : "lat,lon"
        parts = location.split(",")
        return float(parts[0].strip()), float(parts[1].strip())
    except (ValueError, IndexError):
        return None


def get_public_coords(
    location: str | None,
    location_public: str | None,
    has_protected_species: bool,
) -> tuple[float | None, float | None]:
    """
    Retourne les coordonnées à exposer publiquement selon la politique de protection :

    - Si espèce protégée ET location_public disponible → coordonnées floutées pré-calculées.
    - Si espèce protégée SANS location_public → masquage total (None, None).
    - Si espèce non protégée → coordonnées réelles.

    C'est le point d'entrée unique pour toute exposition publique de coordonnées GPS.
    """
    if has_protected_species:
        if location_public:
            parsed = parse_location_string(location_public)
            return parsed if parsed else (None, None)
        # Pas de coordonnées floutées disponibles → masquage complet
        return None, None

    if location:
        parsed = parse_location_string(location)
        return parsed if parsed else (None, None)

    return None, None


def get_public_zone_label(latitude: float | None, longitude: float | None) -> str | None:
    """
    Retourne une étiquette textuelle approximative de la zone géographique
    pour les espèces protégées dont les coordonnées sont masquées.
    Exemple : "Zone de Dakar", "Zone de Saint-Louis".

    Pour un MVP, on se base sur des grandes régions du Sénégal (extensible).
    """
    if latitude is None or longitude is None:
        return "Localisation protégée"

    # Carte approximative des grandes régions du Sénégal (lat_min, lat_max, lon_min, lon_max, label)
    REGIONS = [
        (14.5, 15.1, -17.6, -17.0, "Zone de Dakar"),
        (15.8, 16.2, -16.7, -16.2, "Zone de Saint-Louis"),
        (12.3, 13.0, -16.8, -16.2, "Zone de Ziguinchor"),
        (13.7, 14.3, -16.8, -16.1, "Zone de Kaolack"),
        (14.6, 15.0, -14.5, -13.8, "Zone de Tambacounda"),
        (14.5, 14.9, -17.0, -16.2, "Zone de Thiès"),
        (15.5, 16.0, -15.6, -14.9, "Zone de Louga"),
        (12.8, 13.4, -14.5, -13.7, "Zone de Kédougou"),
    ]
    for lat_min, lat_max, lon_min, lon_max, label in REGIONS:
        if lat_min <= latitude <= lat_max and lon_min <= longitude <= lon_max:
            return label

    return "Zone Ouest-Africaine"
