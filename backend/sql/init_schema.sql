-- =============================================================================
-- BirdSense AI — DDL Schema PostgreSQL 16 / PostGIS
-- Auteur : Pape Alioune Sène
-- Description : Schéma relationnel géospatial complet pour BirdSense AI
-- =============================================================================

-- Activer l'extension PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =============================================================================
-- TABLE : users
-- Utilisateurs de l'application (ornithologues, citoyens-scientifiques)
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    username      VARCHAR(100) NOT NULL UNIQUE,
    hashed_password TEXT NOT NULL,
    full_name     VARCHAR(255),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified   BOOLEAN NOT NULL DEFAULT FALSE,
    role          VARCHAR(50) NOT NULL DEFAULT 'observer',  -- observer | scientist | admin
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email    ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);

-- Trigger de mise à jour automatique de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- TABLE : refresh_tokens
-- Refresh tokens JWT stockés côté serveur (révocation possible)
-- =============================================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash    TEXT NOT NULL UNIQUE,  -- SHA256 du token brut
    expires_at    TIMESTAMPTZ NOT NULL,
    revoked       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id    ON refresh_tokens (user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token_hash ON refresh_tokens (token_hash);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens (expires_at);

-- =============================================================================
-- TABLE : species
-- Catalogue des espèces d'oiseaux avec statut IUCN
-- =============================================================================
CREATE TABLE IF NOT EXISTS species (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scientific_name VARCHAR(255) NOT NULL UNIQUE,  -- Ex: Ardea cinerea
    common_name_fr  VARCHAR(255) NOT NULL,          -- Ex: Héron cendré
    common_name_en  VARCHAR(255),
    family          VARCHAR(100),                   -- Ex: Ardeidae
    order_name      VARCHAR(100),                   -- Ex: Pelecaniformes
    iucn_status     VARCHAR(10) NOT NULL DEFAULT 'LC',
    -- LC=Least Concern | NT=Near Threatened | VU=Vulnerable | EN=Endangered
    -- CR=Critically Endangered | EW=Extinct in the Wild | EX=Extinct
    is_protected    BOOLEAN NOT NULL DEFAULT FALSE, -- True si EN ou CR (floutage GPS)
    ebird_code      VARCHAR(20),                    -- Code espèce eBird
    gbif_taxon_key  INTEGER,                        -- Clé taxonomique GBIF
    audio_url       TEXT,                           -- URL chant BirdNET
    image_url       TEXT,
    description     TEXT,
    habitat         TEXT,
    yolo_class_id   INTEGER,                        -- ID classe dans le modèle YOLO
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_species_iucn_status  ON species (iucn_status);
CREATE INDEX IF NOT EXISTS idx_species_is_protected ON species (is_protected);
CREATE INDEX IF NOT EXISTS idx_species_ebird_code   ON species (ebird_code);
CREATE INDEX IF NOT EXISTS idx_species_yolo_class   ON species (yolo_class_id);

CREATE TRIGGER trg_species_updated_at
    BEFORE UPDATE ON species
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- TABLE : observations
-- Observations géolocalisées (photo ou vidéo) — point principal de la carte
-- =============================================================================
CREATE TABLE IF NOT EXISTS observations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    observed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Coordonnées GPS réelles (stockage interne sécurisé)
    location        GEOGRAPHY(POINT, 4326) NOT NULL,
    -- Coordonnées floutées (5 km) exposées publiquement si espèce protégée
    location_public GEOGRAPHY(POINT, 4326),
    altitude_m      FLOAT,
    location_accuracy_m FLOAT,                     -- Précision GPS en mètres
    media_type      VARCHAR(10) NOT NULL DEFAULT 'photo', -- photo | video
    media_url       TEXT,                           -- URL stockage Supabase Storage
    thumbnail_url   TEXT,
    weather_conditions TEXT,
    notes           TEXT,
    sync_status     VARCHAR(20) NOT NULL DEFAULT 'synced', -- synced | pending | failed
    device_id       VARCHAR(255),                  -- ID appareil mobile source
    -- Floutage : indique si au moins un item contient une espèce protégée
    has_protected_species BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index spatial GiST sur la localisation réelle
CREATE INDEX IF NOT EXISTS idx_observations_location
    ON observations USING GIST (location);

-- Index spatial GiST sur la localisation publique (floutée)
CREATE INDEX IF NOT EXISTS idx_observations_location_public
    ON observations USING GIST (location_public);

-- Index sur les colonnes de filtrage fréquentes
CREATE INDEX IF NOT EXISTS idx_observations_user_id    ON observations (user_id);
CREATE INDEX IF NOT EXISTS idx_observations_observed_at ON observations (observed_at DESC);
CREATE INDEX IF NOT EXISTS idx_observations_sync_status ON observations (sync_status);

CREATE TRIGGER trg_observations_updated_at
    BEFORE UPDATE ON observations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- TABLE : observation_items
-- Détails des espèces détectées dans une observation (1 obs → N espèces)
-- =============================================================================
CREATE TABLE IF NOT EXISTS observation_items (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    observation_id      UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
    species_id          UUID REFERENCES species(id) ON DELETE SET NULL,
    -- Nom brut si l'espèce n'est pas encore dans le catalogue
    species_raw_name    VARCHAR(255),
    count               INTEGER NOT NULL DEFAULT 1 CHECK (count > 0),
    confidence_score    FLOAT CHECK (confidence_score BETWEEN 0.0 AND 1.0),
    -- Bounding box normalisée [x_center, y_center, width, height] format YOLO
    bbox_x_center       FLOAT,
    bbox_y_center       FLOAT,
    bbox_width          FLOAT,
    bbox_height         FLOAT,
    -- Track ID unique attribué par ByteTrack (pour la vidéo)
    track_id            INTEGER,
    bayesian_score      FLOAT CHECK (bayesian_score BETWEEN 0.0 AND 1.0),
    behavior            VARCHAR(100),               -- Vol, Perché, Nidification...
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_obs_items_observation_id ON observation_items (observation_id);
CREATE INDEX IF NOT EXISTS idx_obs_items_species_id     ON observation_items (species_id);
CREATE INDEX IF NOT EXISTS idx_obs_items_confidence     ON observation_items (confidence_score DESC);

-- =============================================================================
-- VUE : v_observations_public
-- Vue sécurisée exposant les coordonnées floutées pour les espèces protégées
-- =============================================================================
CREATE OR REPLACE VIEW v_observations_public AS
SELECT
    o.id,
    o.user_id,
    o.observed_at,
    -- Si espèce protégée : utiliser les coordonnées floutées
    CASE
        WHEN o.has_protected_species AND o.location_public IS NOT NULL
        THEN o.location_public
        ELSE o.location
    END AS location,
    ST_X(
        CASE
            WHEN o.has_protected_species AND o.location_public IS NOT NULL
            THEN o.location_public::geometry
            ELSE o.location::geometry
        END
    ) AS longitude,
    ST_Y(
        CASE
            WHEN o.has_protected_species AND o.location_public IS NOT NULL
            THEN o.location_public::geometry
            ELSE o.location::geometry
        END
    ) AS latitude,
    o.has_protected_species,
    o.media_type,
    o.thumbnail_url,
    o.notes,
    o.observed_at,
    o.created_at
FROM observations o
WHERE o.sync_status = 'synced';

-- =============================================================================
-- Données initiales : espèces communes (seed minimal pour les tests)
-- =============================================================================
INSERT INTO species (scientific_name, common_name_fr, common_name_en, family, order_name, iucn_status, is_protected, ebird_code, yolo_class_id)
VALUES
    ('Ardea cinerea',        'Héron cendré',         'Grey Heron',           'Ardeidae',     'Pelecaniformes', 'LC', FALSE, 'grhher1',  0),
    ('Passer domesticus',    'Moineau domestique',   'House Sparrow',        'Passeridae',   'Passeriformes',  'LC', FALSE, 'houspa',   1),
    ('Columba livia',        'Pigeon biset',         'Rock Pigeon',          'Columbidae',   'Columbiformes',  'LC', FALSE, 'rocpig',   2),
    ('Falco peregrinus',     'Faucon pèlerin',       'Peregrine Falcon',     'Falconidae',   'Falconiformes',  'LC', FALSE, 'perfal',   3),
    ('Phoenicopterus roseus','Flamant rose',         'Greater Flamingo',     'Phoenicopteridae','Phoenicopteriformes','LC',FALSE,'grefla1',4),
    ('Gyps africanus',       'Vautour africain',     'African White-backed Vulture','Accipitridae','Accipitriformes','CR',TRUE,'afwvul1',5),
    ('Leptoptilos crumenifer','Marabout d''Afrique', 'Marabou Stork',        'Ciconiidae',   'Ciconiiformes',  'LC', FALSE, 'marsto1',  6),
    ('Pelecanus onocrotalus','Pélican blanc',        'Great White Pelican',  'Pelecanidae',  'Pelecaniformes', 'LC', FALSE, 'grwpel1',  7),
    ('Scopus umbretta',      'Ombrette africaine',   'Hamerkop',             'Scopidae',     'Pelecaniformes', 'LC', FALSE, 'hamerk1',  8),
    ('Vanellus spinosus',    'Vanneau éperonné',     'Spur-winged Lapwing',  'Charadriidae', 'Charadriiformes','LC', FALSE, 'spwlap1',  9)
ON CONFLICT (scientific_name) DO NOTHING;
