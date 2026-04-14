# OpenStreetMap Skills

Complete OpenStreetMap integration skills for AI coding assistants. Cover Flutter, Kotlin/Android, backend services, and ISP/telecom applications.

## 📦 Available Skills

| Skill | Description | Triggers |
|-------|-------------|----------|
| **[osm-flutter](skills/osm-flutter/SKILL.md)** | OSM integration for Flutter apps using flutter_map, markers, polylines, clustering, offline maps, location tracking, tile caching | `openstreetmap flutter`, `flutter_map`, `flutter osm`, `add map to flutter` |
| **[osm-kotlin](skills/osm-kotlin/SKILL.md)** | OSM integration for Android/Kotlin using osmdroid, MapView, markers, overlays, GPS tracking, offline maps, Jetpack Compose | `openstreetmap kotlin`, `osmdroid`, `android map`, `kotlin map` |
| **[osm-services](skills/osm-services/SKILL.md)** | Backend services: OSRM routing, Nominatim geocoding, Overpass API, tile servers, Valhalla routing, Docker setup | `osrm`, `nominatim`, `overpass api`, `openstreetmap routing`, `openstreetmap docker` |
| **[osm-isp](skills/osm-isp/SKILL.md)** | OSM for ISP/telecom: FTTH network planning, infrastructure management, coverage mapping, field technician tracking, telecom tags | `openstreetmap isp`, `openstreetmap telecom`, `openstreetmap ftth`, `network planning` |

## 🚀 Installation

### Via Claude Code Skills

```bash
# Install from GitHub repository
skills install github:lfcamarac/openstreetmap-skills
```

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/lfcamarac/openstreetmap-skills.git
```

2. Reference the skills in your project's `.claude-plugin/plugin.json`:
```json
{
  "skills": [
    { "name": "osm-flutter", "path": "./openstreetmap-skills/skills/osm-flutter" },
    { "name": "osm-kotlin", "path": "./openstreetmap-skills/skills/osm-kotlin" },
    { "name": "osm-services", "path": "./openstreetmap-skills/skills/osm-services" },
    { "name": "osm-isp", "path": "./openstreetmap-skills/skills/osm-isp" }
  ]
}
```

## 📋 What's Included

### osm-flutter
- flutter_map setup and configuration
- Markers, polylines, polygons, circles
- Marker clustering for large datasets
- GeoJSON overlay and styling
- Offline maps with tile caching
- Location tracking and GPS
- Rich attribution widgets
- Mobile-first design patterns

### osm-kotlin
- osmdroid setup for Android
- MapView, markers, overlays
- Polylines, polygons, circles
- GPS tracking and location
- Offline maps with MBTiles
- Jetpack Compose integration
- Material Design map UIs
- Routing with OSRM integration

### osm-services
- OSRM routing server (Docker)
- Nominatim geocoding server
- Overpass API queries
- Valhalla routing + isochrones
- Tile server self-hosting
- Flutter/Kotlin integration examples
- Service comparison and rate limits
- Production deployment guidelines

### osm-isp
- FTTH network planning on OSM
- Fiber optic route design
- Antenna and node placement
- Coverage zone calculation
- Technician tracking and dispatch
- Infrastructure inventory maps
- Telecom OSM tags guide
- ISP dashboard examples

## 📚 Documentation

Full documentation for OSRM API and FlatBuffers format is available in the companion repository: [geofensing-os](https://github.com/lfcamarac/geofensing-os)

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-skill`)
3. Commit your changes (`git commit -m 'Add amazing skill'`)
4. Push to the branch (`git push origin feature/amazing-skill`)
5. Open a Pull Request

## 🙏 Credits

- **OpenStreetMap** — The free wiki world map
- **OSRM** — Open Source Routing Machine
- **Nominatim** — OpenStreetMap geocoding service
- **Overpass API** — Read-only API for OSM data
- **Valhalla** — Open-source routing engine

## 📬 Support

- Issues: [GitHub Issues](https://github.com/lfcamarac/openstreetmap-skills/issues)
- Author: [LFCamara](https://github.com/lfcamarac)
