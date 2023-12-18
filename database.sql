CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    feature_type VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL
);

CREATE EXTENSION postgis;

CREATE TABLE areas (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    geometry GEOMETRY(Polygon, 4326) NOT NULL
);


INSERT INTO locations (name, feature_type, latitude, longitude) VALUES
('Central Park', 'Park', 40.785091, -73.968285),
('Golden Gate Bridge', 'Bridge', 37.819929, -122.478255),
('Eiffel Tower', 'Monument', 48.858370, 2.294481),
('Sahara Desert', 'Desert', 23.416203, 25.662830),
('Great Barrier Reef', 'Reef', -18.2871, 147.6992),
('Mount Everest', 'Mountain', 27.9881, 86.9250),
('Times Square', 'Plaza', 40.7580, -73.9855),
('Amazon Rainforest', 'Rainforest', -3.4653, -62.2159),
('Grand Canyon', 'Canyon', 36.1069, -112.1129),
('Sydney Opera House', 'Opera House', -33.8568, 151.2153);

INSERT INTO areas (name, geometry) VALUES
('Area 1', ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0))', 4326)),
('Area 2', ST_GeomFromText('POLYGON((5 5, 10 5, 10 10, 5 10, 5 5))', 4326)),
('Area 3', ST_GeomFromText('POLYGON((3 3, 6 3, 6 6, 3 6, 3 3))', 4326)),
('Area 4', ST_GeomFromText('POLYGON((-1 -1, -4 -1, -4 -4, -1 -4, -1 -1))', 4326)),
('Area 5', ST_GeomFromText('POLYGON((-2 2, -5 2, -5 5, -2 5, -2 2))', 4326)),
('Area 6', ST_GeomFromText('POLYGON((10 10, 14 10, 14 14, 10 14, 10 10))', 4326)),
('Area 7', ST_GeomFromText('POLYGON((15 15, 20 15, 20 20, 15 20, 15 15))', 4326)),
('Area 8', ST_GeomFromText('POLYGON((12 12, 16 12, 16 16, 12 16, 12 12))', 4326)),
('Area 9', ST_GeomFromText('POLYGON((-3 -3, -7 -3, -7 -7, -3 -7, -3 -3))', 4326)),
('Area 10', ST_GeomFromText('POLYGON((-4 4, -8 4, -8 8, -4 8, -4 4))', 4326));

SELECT * FROM locations WHERE feature_type = 'Park';

SELECT ST_Distance(l1.geom, l2.geom) AS distance
FROM (SELECT ST_MakePoint(longitude, latitude)::geography AS geom FROM locations WHERE id = 1) l1,
     (SELECT ST_MakePoint(longitude, latitude)::geography AS geom FROM locations WHERE id = 2) l2;

SELECT name, ST_Area(geometry::geography) AS area
FROM areas;

EXPLAIN SELECT * FROM locations WHERE feature_type = 'Park';

SELECT * FROM locations
ORDER BY name ASC
LIMIT 5;

CREATE INDEX idx_feature_type ON locations(feature_type);

SELECT name FROM locations
WHERE ST_DWithin(
    ST_MakePoint(longitude, latitude)::geography,
    ST_MakePoint(-73.968285, 40.785091)::geography,
    10000
);

-- Temporary table to hold parks
WITH Parks AS (
    SELECT id, name, ST_MakePoint(longitude, latitude)::geography AS geom
    FROM locations
    WHERE feature_type = 'Park'
),
-- Select parks within 10,000 meters of a specific point
NearbyParks AS (
    SELECT name
    FROM Parks
    WHERE ST_DWithin(
        geom,
        ST_MakePoint(-73.968285, 40.785091)::geography, -- Example coordinates
        10000 -- Distance in meters
    )
)
SELECT * FROM NearbyParks;
