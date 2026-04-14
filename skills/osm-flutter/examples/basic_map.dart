// Example: Basic OpenStreetMap in Flutter
// Run: flutter create my_map_app && replace lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenStreetMap Flutter',
      home: const BasicMapScreen(),
    );
  }
}

class BasicMapScreen extends StatelessWidget {
  const BasicMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenStreetMap')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(-12.0464, -77.0428),  // Lima, Peru
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.miapp.mipaquete',
          ),
          // Markers
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(-12.0464, -77.0428),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 32),
              ),
              Marker(
                point: const LatLng(-12.0500, -77.0460),
                width: 40,
                height: 40,
                child: const Icon(Icons.wifi, color: Colors.blue, size: 32),
              ),
            ],
          ),
          // Route
          PolylineLayer(
            polylines: [
              Polyline(
                points: const [
                  LatLng(-12.0464, -77.0428),
                  LatLng(-12.0500, -77.0460),
                ],
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),
          // Coverage area
          PolygonLayer(
            polygons: [
              Polygon(
                points: const [
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
          ),
          // Attribution
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }
}
