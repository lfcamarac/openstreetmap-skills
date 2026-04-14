// Example: ISP Dashboard with OpenStreetMap in Flutter

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const ISPDashboard());

class ISPDashboard extends StatelessWidget {
  const ISPDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MikroISP Dashboard',
      home: const DashboardScreen(),
    );
  }
}

// Models
class Antena {
  final String id;
  final String nombre;
  final double lat, lng;
  final bool online;
  final int clientesConectados;
  final String tipo;  // 'PTP', 'PTMP', 'OLT'

  const Antena({
    required this.id, required this.nombre,
    required this.lat, required this.lng,
    required this.online, required this.clientesConectados,
    required this.tipo,
  });
}

class Cliente {
  final String nombre;
  final double lat, lng;
  final bool conectado;
  final String plan;

  const Cliente({
    required this.nombre, required this.lat, required this.lng,
    required this.conectado, required this.plan,
  });
}

class FiberRoute {
  final String name;
  final List<LatLng> points;
  final String status;  // 'activa', 'planificada'

  const FiberRoute({required this.name, required this.points, required this.status});
}

// Sample data
const antenas = [
  Antena(id: 'a1', nombre: 'Antena Norte', lat: -12.0400, lng: -77.0400,
    online: true, clientesConectados: 45, tipo: 'PTP'),
  Antena(id: 'a2', nombre: 'Antena Sur', lat: -12.0550, lng: -77.0500,
    online: true, clientesConectados: 32, tipo: 'PTMP'),
  Antena(id: 'a3', nombre: 'Antena Este', lat: -12.0450, lng: -77.0300,
    online: false, clientesConectados: 0, tipo: 'OLT'),
];

const clientes = [
  Cliente(nombre: 'Juan P.', lat: -12.0420, lng: -77.0420, conectado: true, plan: '50Mbps'),
  Cliente(nombre: 'Maria L.', lat: -12.0480, lng: -77.0480, conectado: true, plan: '100Mbps'),
  Cliente(nombre: 'Carlos R.', lat: -12.0520, lng: -77.0450, conectado: false, plan: '25Mbps'),
  Cliente(nombre: 'Ana G.', lat: -12.0440, lng: -77.0360, conectado: true, plan: '50Mbps'),
  Cliente(nombre: 'Pedro M.', lat: -12.0500, lng: -77.0520, conectado: true, plan: '100Mbps'),
];

const fiberRoutes = [
  FiberRoute(
    name: 'Troncal Norte',
    points: [LatLng(-12.0400, -77.0400), LatLng(-12.0430, -77.0430), LatLng(-12.0460, -77.0460)],
    status: 'activa',
  ),
  FiberRoute(
    name: 'Troncal Sur (planificada)',
    points: [LatLng(-12.0500, -77.0460), LatLng(-12.0530, -77.0490), LatLng(-12.0560, -77.0520)],
    status: 'planificada',
  ),
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MapController _mapController = MapController();
  String? _selectedLayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MikroISP — Red'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => _showLayerSelector(),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(-12.0464, -77.0428),
          initialZoom: 14,
        ),
        children: [
          // Base map
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.isp.mikroisp',
          ),
          // Coverage zones
          if (_shouldShow('cobertura')) _buildCoverageZones(),
          // Antennas
          if (_shouldShow('antenas')) _buildAntenas(),
          // Fiber routes
          if (_shouldShow('fibra')) _buildFiberRoutes(),
          // Clients
          if (_shouldShow('clientes')) _buildClientes(),
          // Attribution
          const RichAttributionWidget(
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
      // Stats overlay
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStats(),
        child: const Icon(Icons.bar_chart),
      ),
    );
  }

  bool _shouldShow(String layer) => _selectedLayer == null || _selectedLayer == layer;

  PolygonLayer _buildCoverageZones() {
    return PolygonLayer(
      polygons: [
        Polygon(
          points: _generateCirclePoints(const LatLng(-12.0450, -77.0430), radiusKm: 1.5),
          color: Colors.blue.withOpacity(0.15),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
        ),
        Polygon(
          points: _generateCirclePoints(const LatLng(-12.0520, -77.0480), radiusKm: 1.0),
          color: Colors.green.withOpacity(0.15),
          borderColor: Colors.green,
          borderStrokeWidth: 2,
        ),
      ],
    );
  }

  MarkerLayer _buildAntenas() {
    return MarkerLayer(
      markers: antenas.map((a) => Marker(
        point: LatLng(a.lat, a.lng),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showAntenaDetail(a),
          child: Stack(
            children: [
              Icon(
                a.online ? Icons.cell_tower : Icons.cell_tower_outlined,
                color: a.online ? Colors.green : Colors.red,
                size: 40,
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${a.clientesConectados}',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  PolylineLayer _buildFiberRoutes() {
    return PolylineLayer(
      polylines: fiberRoutes.map((route) => Polyline(
        points: route.points,
        strokeWidth: 5,
        color: route.status == 'activa' ? Colors.green : Colors.orange.withOpacity(0.7),
      )).toList(),
    );
  }

  MarkerLayer _buildClientes() {
    return MarkerLayer(
      markers: clientes.map((c) => Marker(
        point: LatLng(c.lat, c.lng),
        width: 30,
        height: 30,
        child: Icon(
          c.conectado ? Icons.wifi : Icons.wifi_off,
          color: c.conectado ? Colors.green : Colors.red,
          size: 24,
        ),
      )).toList(),
    );
  }

  List<LatLng> _generateCirclePoints(LatLng center, {double radiusKm = 1.0}) {
    const numPoints = 64;
    final radiusRad = radiusKm / 6371.0;
    return List.generate(numPoints, (i) {
      final angle = 2 * 3.14159 * i / numPoints;
      final lat = center.latitude + (radiusRad * 180 / 3.14159) * (angle.cos());
      final lng = center.longitude + (radiusRad * 180 / 3.14159) * (angle.sin()) / (center.latitude * 3.14159 / 180).cos();
      return LatLng(lat, lng);
    });
  }

  void _showLayerSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['cobertura', 'antenas', 'fibra', 'clientes', 'todas']
            .map((layer) => ListTile(
                  title: Text(layer[0].toUpperCase() + layer.substring(1)),
                  onTap: () {
                    setState(() {
                      _selectedLayer = layer == 'todas' ? null : layer;
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showAntenaDetail(Antena antena) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(antena.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${antena.tipo}'),
            Text('Estado: ${antena.online ? "Online" : "Offline"}'),
            Text('Clientes: ${antena.clientesConectados}'),
            Text('Coords: ${antena.lat.toStringAsFixed(4)}, ${antena.lng.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen de Red'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('Antenas', '${antenas.where((a) => a.online).length}/${antenas.length}', Colors.green),
            _statRow('Clientes', '${clientes.where((c) => c.conectado).length}/${clientes.length}', Colors.blue),
            _statRow('Rutas activas', '${fiberRoutes.where((r) => r.status == 'activa').length}', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

extension on double {
  double cos() => this;  // Use dart:math in production
  double sin() => this;  // Use dart:math in production
}
