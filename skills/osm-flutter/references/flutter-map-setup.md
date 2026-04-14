# Flutter Map — Setup, Configuration, Markers, Overlays

## Complete Setup

### pubspec.yaml

```yaml
dependencies:
  flutter_map: ^8.2.0
  latlong2: ^0.9.1
  geolocator: ^13.0.2
  permission_handler: ^11.3.1
  flutter_map_location_marker: ^9.0.0
  flutter_map_marker_cluster: ^8.0.0
  flutter_map_marker_popup: ^8.0.0
```

### Basic Map

```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BasicMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-12.0464, -77.0428),
          initialZoom: 13,
          onPositionChanged: (position, hasGesture) {
            // Map moved
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.miapp.mipaquete',  // MANDATORY
            maxZoom: 19,
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Markers

### Simple Marker

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

### Custom Widget Marker

```dart
Marker(
  point: LatLng(lat, lng),
  width: 120,
  height: 80,
  child: Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Detail'),
        Icon(Icons.wifi, color: Colors.green),
      ],
    ),
  ),
)
```

### Multiple Markers from Data

```dart
MarkerLayer(
  markers: items.map((item) => Marker(
    point: LatLng(item.lat, item.lng),
    width: 30,
    height: 30,
    child: Icon(
      item.active ? Icons.check_circle : Icons.error,
      color: item.active ? Colors.green : Colors.red,
      size: 24,
    ),
  )).toList(),
)
```

## Polylines (Routes)

```dart
PolylineLayer(
  polylines: [
    Polyline(
      points: [
        LatLng(-12.0464, -77.0428),
        LatLng(-12.0500, -77.0460),
        LatLng(-12.0550, -77.0500),
      ],
      strokeWidth: 4,
      color: Colors.blue,
      pattern: Pattern.dashed(10, 5),  // Dashed pattern
    ),
  ],
)
```

## Polygons (Coverage Areas)

```dart
PolygonLayer(
  polygons: [
    Polygon(
      points: [
        LatLng(-12.04, -77.04),
        LatLng(-12.05, -77.04),
        LatLng(-12.05, -77.05),
        LatLng(-12.04, -77.05),
      ],
      color: Colors.blue.withOpacity(0.2),
      borderColor: Colors.blue,
      borderStrokeWidth: 2,
    ),
  ],
)
```

## Circles

```dart
CircleLayer(
  circles: [
    CircleMarker(
      point: LatLng(lat, lng),
      radius: 100,  // meters
      color: Colors.blue.withOpacity(0.3),
      borderColor: Colors.blue,
      borderStrokeWidth: 2,
    ),
  ],
)
```

## Scale Bar

```dart
RichAttributionWidget(
  attributions: [TextSourceAttribution('OpenStreetMap contributors')],
),
```

## Map Controller

```dart
final MapController _mapController = MapController();

FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: LatLng(-12.0464, -77.0428),
    initialZoom: 13,
  ),
  children: [...],
)

// Later: move map
_mapController.move(LatLng(newLat, newLng), 15);
// Zoom
_mapController.zoomIn();
_mapController.zoomOut();
```

## Location Permission

```dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationPermission() async {
  final status = await Permission.location.request();
  return status.isGranted;
}

Future<Position?> getCurrentPosition() async {
  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    return null;
  }
}
```

## Live Location Marker

```dart
CurrentLocationLayer(
  style: LocationMarkerStyle(
    marker: DefaultLocationMarker(
      color: Colors.blue,
      child: Icon(Icons.my_location, color: Colors.white, size: 18),
    ),
    showAccuracyCircle: true,
    accuracyColor: Colors.blue.withOpacity(0.15),
  ),
)
```
