---
name: osm-isp
description: OpenStreetMap for ISP and telecom companies. FTTH network planning, infrastructure management, coverage mapping, field technician tracking, telecom OSM tags, and Overpass API queries for telecom infrastructure.
triggers:
  - openstreetmap isp
  - openstreetmap telecom
  - openstreetmap ftth
  - openstreetmap network planning
  - openstreetmap fibra optica
  - openstreetmap antenna
  - openstreetmap telecom tags
  - openstreetmap cobertura
  - openstreetmap tecnicos
  - openstreetmap infrastructure
  - map isp dashboard
  - network map flutter
  - network map android
  - openstreetmap technician tracking
  - openstreetmap coverage area
  - openstreetmap fiber route
  - telecom osm
  - isp osm
---

# OpenStreetMap — ISP & Telecom

## Overview

Specialized guide for using OpenStreetMap in ISP and telecommunications: network planning, infrastructure management, coverage mapping, and field operations.

## Quick Start — ISP Dashboard (Flutter)

```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Antenna marker
Marker buildAntennaMarker(Antenna antena) {
  return Marker(
    point: LatLng(antena.lat, antena.lng),
    width: 50, height: 50,
    child: Icon(
      antena.online ? Icons.cell_tower : Icons.cell_tower_outlined,
      color: antena.online ? Colors.green : Colors.red,
      size: 40,
    ),
  );
}

// Coverage zone
Polygon buildCoverageZone(LatLng center, double radiusKm) {
  return Polygon(
    points: _generateCirclePoints(center, radiusKm),
    color: Colors.blue.withOpacity(0.15),
    borderColor: Colors.blue,
    borderStrokeWidth: 2,
  );
}

// Fiber route
Polyline buildFiberRoute(List<LatLng> points, {bool active = true}) {
  return Polyline(
    points: points,
    strokeWidth: 5,
    color: active ? Colors.green : Colors.orange.withOpacity(0.7),
  );
}
```

## Telecom OSM Tags

| Tag | Value | Description |
|-----|-------|-------------|
| `man_made` | `mast`, `tower` | Physical structure |
| `tower:type` | `communication` | Tower type |
| `tower:construction` | `lattice`, `guyed_tube` | Construction type |
| `telecom` | `connection_point` | Network connection point |
| `telecom:cable` | `fiber`, `copper` | Cable type |
| `cable:layer` | `underground`, `overhead` | Cable placement |
| `communication:cell` | `4g`, `5g`, `wifi` | Cell technology |
| `communication:radio` | `microwave`, `radio` | Radio type |
| `frequency` | `5800`, `2400` | Frequency in MHz |
| `antenna:direction` | `0-360` | Antenna direction degrees |
| `antenna:gain` | `0-30` | Gain in dBi |
| `operator` | `CompanyName` | Operator name |
| `height` | `25` | Height in meters |

## Overpass Queries for Telecom

```dart
// Find existing telecom infrastructure
Future<List<Map>> findTelecomInfra(LatLng center, double radius) async {
  final query = '''
    [out:json];
    (
      nwr["man_made"="mast"](around:$radius,${center.latitude},${center.longitude});
      nwr["tower:type"="communication"](around:$radius,${center.latitude},${center.longitude});
      nwr["telecom"="connection_point"](around:$radius,${center.latitude},${center.longitude});
      nwr["telecom"="exchange"](around:$radius,${center.latitude},${center.longitude});
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
    'type': e['tags']['tower:type'] ?? e['tags']['man_made'],
  }).toList();
}
```

## Field Technician Map

### Flutter

```dart
class TechnicianMap extends StatelessWidget {
  final List<Technician> technicians;
  final List<WorkOrder> workOrders;

  TechnicianMap({required this.technicians, required this.workOrders});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(-12.0464, -77.0428),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.isp.technicians',
        ),
        // Work orders
        MarkerLayer(
          markers: workOrders.map((wo) => Marker(
            point: LatLng(wo.lat, wo.lng),
            width: 30, height: 30,
            child: Icon(
              wo.urgente ? Icons.warning : Icons.build,
              color: wo.urgente ? Colors.red : Colors.orange,
              size: 28,
            ),
          )).toList(),
        ),
        // Technicians
        MarkerLayer(
          markers: technicians.map((tech) => Marker(
            point: LatLng(tech.lat, tech.lng),
            width: 50, height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: tech.available ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(tech.nombre.substring(0, 2).toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
```

## Coverage Area Calculation

```dart
List<LatLng> generateCoveragePolygon(LatLng center, double radiusMeters) {
  const numPoints = 64;
  final d = radiusMeters / 6371000;
  final points = <LatLng>[];

  for (int i = 0; i < numPoints; i++) {
    final angle = 2 * pi * i / numPoints;
    final lat1 = _degToRad(center.latitude);
    final lon1 = _degToRad(center.longitude);

    final lat2 = asin(sin(lat1) * cos(d) + cos(lat1) * sin(d) * cos(angle));
    final lon2 = lon1 + atan2(
      sin(angle) * sin(d) * cos(lat1),
      cos(d) - sin(lat1) * sin(lat2));

    points.add(LatLng(_radToDeg(lat2), _radToDeg(lon2)));
  }
  return points;
}

double _degToRad(double deg) => deg * pi / 180;
double _radToDeg(double rad) => rad * 180 / pi;
```

## Network Alert Map

```dart
class AlertMap extends StatelessWidget {
  final List<NetworkAlert> alerts;
  AlertMap({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: LatLng(-12.0464, -77.0428), initialZoom: 12),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.isp.alerts',
        ),
        MarkerLayer(
          markers: alerts.map((alert) => Marker(
            point: LatLng(alert.lat, alert.lng),
            width: 40, height: 40,
            child: Icon(
              alert.severity == 'critical' ? Icons.error :
              alert.severity == 'warning' ? Icons.warning : Icons.info,
              color: alert.severity == 'critical' ? Colors.red :
                     alert.severity == 'warning' ? Colors.orange : Colors.blue,
              size: 32,
            ),
          )).toList(),
        ),
      ],
    );
  }
}
```

## ROI: OSM vs Proprietary GIS

| Metric | Proprietary GIS | OSM | Savings |
|--------|----------------|-----|---------|
| License | $5,000-$20,000/year | $0 | 100% |
| Map data | $2,000-$10,000/year | $0 | 100% |
| Updates | $1,000-$5,000/year | Community | 100% |
| Year 1 total | $8,000-$35,000 | $2,000-$5,000 | 70-85% |
| Year 3 total | $24,000-$105,000 | $6,000-$15,000 | 75-85% |

## When to Use This Skill

- Planning FTTH/fiber optic networks
- Mapping ISP infrastructure (antennas, nodes, cables)
- Coverage area visualization
- Field technician dispatch
- Network alert monitoring
- Expansion analysis
- Competitor mapping

## Key Patterns

1. **Layer architecture** — Stack coverage, infrastructure, clients, alerts
2. **OSM tags** — Use standard telecom tags when contributing to OSM
3. **Overpass API** — Query existing infrastructure before planning
4. **OSRM routing** — Optimize technician routes
5. **Contribute back** — Add your infrastructure to improve the map for everyone

## References

- `references/isp-planning.md` — FTTH planning patterns, coverage analysis
- `references/telecom-tags.md` — Complete OSM tags for telecom infrastructure
- `references/overpass-telecom.md` — Overpass queries for telecom infrastructure
- `references/technician-tracking.md` — Real-time technician tracking patterns
- `examples/isp_dashboard.dart` — Complete ISP dashboard
- `examples/field_report.kt` — Field technician reporting app
