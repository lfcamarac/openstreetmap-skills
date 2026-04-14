# Flutter Map — Clustering, Offline, GeoJSON, Animations

## Marker Clustering

### Setup

```yaml
dependencies:
  flutter_map_marker_cluster: ^8.0.0
```

### Basic Clustering

```dart
MarkerClusterLayerWidget(
  options: MarkerClusterLayerOptions(
    maxClusterRadius: 45,
    size: Size(40, 40),
    alignment: Alignment.center,
    padding: EdgeInsets.all(50),
    maxZoom: 15,
    markers: items.map((item) => Marker(
      point: LatLng(item.lat, item.lng),
      width: 30,
      height: 30,
      child: Icon(Icons.location_on,
        color: item.active ? Colors.green : Colors.red, size: 24),
    )).toList(),
    builder: (context, markers) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            markers.length.toString(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    },
  ),
)
```

### Cluster with Custom Icons

```dart
builder: (context, markers) {
  final count = markers.length;
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: count > 50 ? Colors.red : count > 20 ? Colors.orange : Colors.blue,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Stack(
      children: [
        Center(
          child: Text(
            count.toString(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: Icon(Icons.group, color: Colors.white70, size: 14),
        ),
      ],
    ),
  );
},
```

---

## Offline Maps

### Setup

```yaml
dependencies:
  flutter_map_tile_caching: ^9.0.0
  flutter_map_cancellable_tile_provider: ^3.0.0
```

### Initialize

```dart
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

// Initialize at app start
await FlutterMapTileCaching().initialise();
```

### Download Region

```dart
Future<void> downloadRegion({
  required double lat,
  required double lng,
  required int radiusKm,
  required int minZoom,
  required int maxZoom,
  required String storeName,
}) async {
  final store = FMTCStore(storeName);
  await store.create();

  final download = await store.download.start(
    tileLayer: TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.miapp.mipaquete',
    ),
    center: LatLng(lat, lng),
    minZoom: minZoom,
    maxZoom: maxZoom,
    radiusKm: radiusKm,
  );

  // Monitor progress
  download.stream.listen((event) {
    if (event is DownloadingTileEvent) {
      print('Progress: ${event.progress}%');
    } else if (event is DownloadFinishedEvent) {
      print('Done: ${event.totalTiles} tiles downloaded');
    }
  });
}
```

### Use Offline Map

```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.miapp.mipaquete',
  tileProvider: FMTCProvider(storeName: 'myOfflineMap'),
)
```

### Manage Downloads

```dart
// List stores
final stores = await FMTCStore.all();

// Delete store
await FMTCStore('myOfflineMap').delete();

// Get download status
final store = FMTCStore('myOfflineMap');
final info = await store.download.get();
```

---

## GeoJSON

### Setup

```yaml
dependencies:
  flutter_map_geojson: ^2.0.0
```

### Load GeoJSON

```dart
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

Future<List<Widget>> loadGeoJsonLayers(String geojsonSource) async {
  final layers = <Widget>[];
  final data = json.decode(geojsonSource);

  final parser = GeoJsonParser(geojson: data);

  if (parser.points.isNotEmpty) {
    layers.add(MarkerLayer(
      markers: parser.points.map((p) => Marker(
        point: p,
        width: 30,
        height: 30,
        child: Icon(Icons.location_on, color: Colors.blue, size: 24),
      )).toList(),
    ));
  }

  if (parser.polygons.isNotEmpty) {
    layers.add(PolygonLayer(polygons: parser.polygons));
  }

  if (parser.polylines.isNotEmpty) {
    layers.add(PolylineLayer(polylines: parser.polylines));
  }

  return layers;
}
```

### GeoJSON from URL

```dart
Future<List<Widget>> loadGeoJsonFromUrl(String url) async {
  final response = await http.get(Uri.parse(url));
  return loadGeoJsonLayers(response.body);
}
```

---

## Map Animations

### Setup

```yaml
dependencies:
  flutter_map_animations: ^5.0.0
```

### Animated Map Controller

```dart
import 'package:flutter_map_animations/flutter_map_animations.dart';

class AnimatedMap extends StatefulWidget {
  @override
  State<AnimatedMap> createState() => _AnimatedMapState();
}

class _AnimatedMapState extends State<AnimatedMap> with TickerProviderStateMixin {
  final _animatedController = AnimatedMapController();

  void _flyTo(LatLng target) {
    _animatedController.animateTo(
      center: target,
      zoom: 16,
      curve: Curves.easeInOut,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _animatedController.mapController,
      options: MapOptions(
        initialCenter: LatLng(-12.0464, -77.0428),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.miapp.mipaquete',
        ),
      ],
    );
  }
}
```

### Animated Marker

```dart
AnimatedMarker(
  point: movingPosition,
  builder: (context, offset, rotation) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Icon(Icons.directions_car, color: Colors.blue, size: 30),
      ),
    );
  },
  duration: Duration(milliseconds: 500),
  curve: Curves.easeInOut,
)
```

---

## Popups on Markers

### Setup

```yaml
dependencies:
  flutter_map_marker_popup: ^8.0.0
```

### Popup Layer

```dart
PopupMarkerLayer(
  options: PopupMarkerLayerOptions(
    markers: myMarkers,
    popupDisplayOptions: PopupDisplayOptions(
      builder: (context, marker) => Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(marker.point.latitude.toString().substring(0, 6),
                style: TextStyle(fontWeight: FontWeight.bold)),
              Text(marker.point.longitude.toString().substring(0, 6)),
            ],
          ),
        ),
      ),
    ),
  ),
)
```

---

## Tile Sources Comparison

| Source | URL | Style | Max Zoom | Notes |
|--------|-----|-------|----------|-------|
| OSM Default | `tile.openstreetmap.org/{z}/{x}/{y}.png` | Standard | 19 | Free, policy restrictions |
| CartoDB Light | `{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png` | Clean, light | 20 | Good for overlays |
| CartoDB Dark | `{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png` | Dark | 20 | Good for night mode |
| OpenTopoMap | `tile.opentopomap.org/{z}/{x}/{y}.png` | Topographic | 17 | Elevation lines |
| Wikimedia | `maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png` | OSM with labels | 18 | Wikimedia style |

---

## OSMF Tile Policy — Compliance Checklist

- [x] `userAgentPackageName` set to app's actual package name
- [x] Attribution widget visible on map
- [x] Tile caching enabled (for production)
- [x] No bulk downloading without permission
- [x] Self-host for high-traffic commercial apps
- [x] Have fallback tile source configured
