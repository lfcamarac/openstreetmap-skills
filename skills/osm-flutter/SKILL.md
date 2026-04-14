---
name: osm-flutter
description: OpenStreetMap integration for Flutter apps. flutter_map setup, markers, polylines, clustering, GeoJSON, offline maps, location tracking, tile caching, and all flutter_map ecosystem plugins.
triggers:
  - openstreetmap flutter
  - flutter_map
  - flutter map
  - flutter osm
  - add map to flutter
  - flutter openstreetmap
  - flutter map markers
  - flutter map clustering
  - flutter offline map
  - flutter map tiles
  - flutter map location
  - flutter map routing
  - flutter map geocoding
  - flutter map geojson
  - flutter map polygon
  - flutter map polyline
  - flutter map overlay
  - flutter map widget
  - flutter map dashboard
---

# OpenStreetMap — Flutter Integration

## Overview

Complete guide for integrating OpenStreetMap into Flutter applications using the flutter_map ecosystem and related packages.

## Quick Start

### 1. Add Dependencies

```yaml
dependencies:
  flutter_map: ^8.2.0
  latlong2: ^0.9.1
  geolocator: ^13.0.2          # GPS
  flutter_map_location_marker: ^9.0.0  # Live location
  flutter_map_marker_cluster: ^8.0.0   # Clustering
  flutter_map_tile_caching: ^9.0.0     # Offline
  flutter_map_geojson: ^2.0.0          # GeoJSON parsing
```

### 2. Basic Map

```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(-12.0464, -77.0428),
    initialZoom: 13,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.miapp.mipaquete',  // REQUIRED
    ),
  ],
)
```

### 3. Markers

```dart
MarkerLayer(
  markers: [
    Marker(
      point: LatLng(-12.0464, -77.0428),
      width: 40,
      height: 40,
      child: Icon(Icons.location_on, color: Colors.red, size: 32),
    ),
  ],
)
```

### 4. Clustering

```dart
MarkerClusterLayerWidget(
  options: MarkerClusterLayerOptions(
    maxClusterRadius: 45,
    markers: myMarkers,
  ),
)
```

## When to Use This Skill

- Adding a map to a Flutter app
- Showing markers on a map
- Implementing map clustering
- Adding offline map support
- Drawing routes/polylines
- Adding GeoJSON layers
- Implementing location tracking
- Creating map dashboards

## Key Rules

1. **User-Agent is MANDATORY** — `userAgentPackageName` must be set to your app's package name. Generic names get blocked.
2. **Attribution required** — Always include `RichAttributionWidget` or equivalent.
3. **Caching required** — Use `flutter_map_tile_caching` for production to comply with OSMF policy.
4. **OSMF policy** — Public tile servers have rate limits. Self-host for production/high traffic.

## Tile Sources

```dart
// OSM default
'https://tile.openstreetmap.org/{z}/{x}/{y}.png'

// CartoDB light
'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'

// CartoDB dark
'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'

// OpenTopoMap
'https://tile.opentopomap.org/{z}/{x}/{y}.png'
```

## Common Patterns

See reference docs for complete implementations.

## References

- `references/flutter-map-setup.md` — Complete setup, configuration, markers, overlays
- `references/flutter-clustering.md` — Marker clustering implementation
- `references/flutter-offline.md` — Offline maps and tile caching
- `references/flutter-geojson.md` — GeoJSON parsing and rendering
- `references/flutter-animations.md` — Smooth map animations
- `references/flutter-tile-sources.md` — All available tile sources and policies
- `examples/basic_map.dart` — Minimal working example
- `examples/dashboard.dart` — Full dashboard with clustering
- `examples/offline_map.dart` — Offline map implementation
