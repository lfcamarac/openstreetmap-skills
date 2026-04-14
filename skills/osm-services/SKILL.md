---
name: osm-services
description: OpenStreetMap backend services: OSRM routing, Nominatim geocoding, Overpass API queries, tile server self-hosting, Docker setup, Valhalla routing, and API integration for Flutter and Kotlin apps.
triggers:
  - osrm
  - nominatim
  - overpass api
  - openstreetmap routing
  - openstreetmap geocoding
  - openstreetmap api
  - osrm self-host
  - nominatim self-host
  - openstreetmap docker
  - openstreetmap backend
  - openstreetmap server
  - tile server
  - valhalla routing
  - graphhopper
  - openstreetmap api integration
  - openstreetmap http
  - reverse geocoding
  - distance matrix
  - isochrones
  - map matching
---

# OpenStreetMap — Backend Services & APIs

## Overview

Self-hosted and public API services that power OpenStreetMap functionality: routing, geocoding, data queries, and tile serving.

## Quick Start — OSRM Routing

### Docker Setup

```bash
# Download OSM data (e.g., South America)
wget https://download.geofabrik.de/south-america-latest.osm.pbf

# Extract
docker run -t --rm -v "$(pwd):/data" ghcr.io/project-osrm/osrm-backend \
  osrm-extract -p /opt/car.lua /data/south-america-latest.osm.pbf

# Partition
docker run -t --rm -v "$(pwd):/data" ghcr.io/project-osrm/osrm-backend \
  osrm-partition /data/south-america-latest.osrm

# Customize
docker run -t --rm -v "$(pwd):/data" ghcr.io/project-osrm/osrm-backend \
  osrm-customize /data/south-america-latest.osrm

# Run server
docker run -dt --name osrm -p 5000:5000 \
  -v "$(pwd):/data" \
  ghcr.io/project-osrm/osrm-backend \
  osrm-routed --algorithm mld /data/south-america-latest.osrm
```

### API Endpoints

```bash
# Route
curl "http://localhost:5000/route/v1/driving/-77.0428,-12.0464;-77.0460,-12.0500?overview=full&geometries=geojson"

# Nearest
curl "http://localhost:5000/nearest/v1/driving/-77.0428,-12.0464"

# Table (distance matrix)
curl "http://localhost:5000/table/v1/driving/-77.0428,-12.0464;-77.0460,-12.0500"

# Match (GPS to roads)
curl "http://localhost:5000/match/v1/driving/-77.0428,-12.0464;-77.0460,-12.0500?overview=full&geometries=geojson"
```

### Flutter Integration

```dart
Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
  final url = Uri.parse(
    'http://localhost:5000/route/v1/driving/'
    '${start.longitude},${start.latitude};'
    '${end.longitude},${end.latitude}'
    '?overview=full&geometries=geojson');

  final response = await http.get(url);
  final data = json.decode(response.body);
  final coords = data['routes'][0]['geometry']['coordinates'] as List;
  return coords.map((c) => LatLng(c[1], c[0])).toList();
}
```

### Kotlin Integration

```kotlin
suspend fun getRoute(start: GeoPoint, end: GeoPoint): List<GeoPoint>? {
    val url = "http://localhost:5000/route/v1/driving/" +
        "${start.longitude},${start.latitude};${end.longitude},${end.latitude}" +
        "?overview=full&geometries=geojson"
    val response = URL(url).readText()
    val json = JSONObject(response)
    val coords = json.getJSONArray("routes")
        .getJSONObject(0).getJSONObject("geometry")
        .getJSONArray("coordinates")

    return (0 until coords.length()).map { i ->
        val c = coords.getJSONArray(i)
        GeoPoint(c.getDouble(1), c.getDouble(0))
    }
}
```

## Quick Start — Nominatim Geocoding

### Docker Setup

```bash
docker run -dt --name nominatim -p 8080:8080 \
  -e PBF_PATH=/data/south-america-latest.osm.pbf \
  -v "$(pwd):/data" \
  mediagis/nominatim:4.4
```

### API Usage

```bash
# Geocode (address → coords)
curl "https://nominatim.openstreetmap.org/search?format=json&q=Lima+Peru&limit=1"

# Reverse (coords → address)
curl "https://nominatim.openstreetmap.org/reverse?format=json&lat=-12.0464&lon=-77.0428"

# Self-hosted
curl "http://localhost:8080/search?format=json&q=Lima+Peru"
```

### Flutter Integration

```dart
Future<LatLng?> geocode(String address) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search?'
    'format=json&q=${Uri.encodeQueryComponent(address)}&limit=1');

  final response = await http.get(url, headers: {
    'User-Agent': 'MiApp/1.0',  // REQUIRED
  });

  final data = json.decode(response.body);
  if (data.isNotEmpty) {
    return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
  }
  return null;
}

Future<String?> reverseGeocode(double lat, double lng) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?'
    'format=json&lat=$lat&lon=$lng');

  final response = await http.get(url, headers: {
    'User-Agent': 'MiApp/1.0',
  });

  final data = json.decode(response.body);
  return data['display_name'];
}
```

## Quick Start — Overpass API

### Query Infrastructure

```dart
// Find all hospitals in area
Future<List<Map>> findHospitals(LatLng center, double radius) async {
  final query = '''
    [out:json];
    (
      node["amenity"="hospital"](around:$radius,${center.latitude},${center.longitude});
      way["amenity"="hospital"](around:$radius,${center.latitude},${center.longitude});
    );
    out center;
  ''';

  final response = await http.post(
    Uri.parse('https://overpass-api.de/api/interpreter'),
    body: query,
  );

  final data = json.decode(response.body);
  return (data['elements'] as List).map((e) => {
    'name': e['tags']['name'] ?? 'Hospital',
    'lat': e['lat'] ?? e['center']?['lat'],
    'lon': e['lon'] ?? e['center']?['lon'],
  }).toList();
}

// Find telecom towers
Future<List<Map>> findTelecomTowers(LatLng center, double radius) async {
  final query = '''
    [out:json];
    (
      nwr["man_made"="mast"](around:$radius,${center.latitude},${center.longitude});
      nwr["tower:type"="communication"](around:$radius,${center.latitude},${center.longitude});
    );
    out center;
  ''';

  final response = await http.post(
    Uri.parse('https://overpass-api.de/api/interpreter'),
    body: query,
  );

  final data = json.decode(response.body);
  return (data['elements'] as List).map((e) => {
    'name': e['tags']['name'] ?? 'Tower',
    'lat': e['lat'] ?? e['center']?['lat'],
    'lon': e['lon'] ?? e['center']?['lon'],
  }).toList();
}
```

## Quick Start — Valhalla (Multimodal Routing + Isochrones)

### Docker Setup

```bash
docker run -dt --name valhalla -p 8002:8002 ghcr.io/gis-ops/docker-valhalla/valhalla:latest
```

### Isochrones

```dart
Future<List<List<LatLng>>> getIsochrones(LatLng center, {List<int> times = const [5, 10, 15]}) async {
  final body = json.encode({
    'locations': [{'lat': center.latitude, 'lon': center.longitude}],
    'costing': 'auto',
    'contours': times.map((t) => {'time': t}).toList(),
    'polygon': true,
  });

  final response = await http.post(
    Uri.parse('http://localhost:8002/isochrone'),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  final data = json.decode(response.body);
  return (data['features'] as List).map((f) {
    final coords = f['geometry']['coordinates'] as List;
    return (coords[0] as List).map((c) {
      final p = c as List;
      return LatLng(p[1], p[0]);
    }).toList();
  }).toList();
}
```

## Tile Server

### Docker Setup

```bash
docker run -dt --name tileserver -p 8080:80 \
  -v "$(pwd)/data:/data" \
  overv/openstreetmap-tile-server \
  run south-america-latest.osm.pbf
```

### Use in Apps

```dart
// Flutter
TileLayer(
  urlTemplate: 'http://localhost:8080/tile/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.miapp.mipaquete',
)
```

```kotlin
// Kotlin
val custom = XYTileSource("MyServer", 0, 19, 256, ".png",
    arrayOf("http://localhost:8080/tile/"))
map.setTileSource(custom)
```

## Service Comparison

| Service | Purpose | Self-Host | RAM Min | Public API |
|---------|---------|-----------|---------|------------|
| **OSRM** | Routing (fast) | Yes | 4GB | router.project-osrm.org |
| **Valhalla** | Routing + isochrones | Yes | 8GB | valhalla1.openstreetmap.de |
| **Nominatim** | Geocoding | Yes | 16GB | nominatim.openstreetmap.org |
| **Overpass** | Data queries | Yes | 32GB | overpass-api.de |
| **Tile Server** | Map tiles | Yes | 8GB | tile.openstreetmap.org |

## Rate Limits

| Service | Free Tier | Limit |
|---------|-----------|-------|
| **OSRM Public** | Yes | No strict limit |
| **Nominatim** | Yes | 1 request/second |
| **Overpass** | Yes | Fair use |
| **Tile OSM** | Yes | Policy restrictions |

> **For production**: Always self-host or use paid providers for reliability.
