---
name: osm-kotlin
description: OpenStreetMap integration for Android/Kotlin apps using osmdroid. MapView setup, markers, polylines, polygons, overlays, GPS tracking, offline maps, Jetpack Compose integration, and routing.
triggers:
  - openstreetmap kotlin
  - openstreetmap android
  - osmdroid
  - osmdroid kotlin
  - android map
  - kotlin map
  - android openstreetmap
  - osmdroid markers
  - osmdroid overlay
  - osmdroid routing
  - osmdroid offline
  - android mapview
  - osmdroid compose
  - osmdroid location
  - osmdroid polyline
  - osmdroid polygon
  - osmdroid marker
  - osmdroid gps
  - osmdroid tracking
  - osmdroid geopackage
  - android gpx
---

# OpenStreetMap — Kotlin/Android Integration

## Overview

Complete guide for integrating OpenStreetMap into Android applications using osmdroid, the most mature OSM library for Android.

## Quick Start

### 1. Dependencies

```gradle
// build.gradle (app level)
dependencies {
    implementation 'org.osmdroid:osmdroid-android:6.1.18'
    implementation 'org.osmdroid:osmdroid-geopackage:6.1.18'  // Offline
}
```

### 2. Permissions

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3. Basic Map

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var map: MapView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // IMPORTANT: Configure BEFORE setContentView
        Configuration.getInstance().load(
            applicationContext,
            PreferenceManager.getDefaultSharedPreferences(applicationContext)
        )

        setContentView(R.layout.activity_main)
        map = findViewById(R.id.map)

        map.setTileSource(TileSourceFactory.MAPNIK)
        map.controller.setZoom(15.0)
        map.controller.setCenter(GeoPoint(-12.0464, -77.0428))
        map.setMultiTouchControls(true)
    }

    override fun onResume() {
        super.onResume()
        map.onResume()  // Required for compass & location
    }

    override fun onPause() {
        super.onPause()
        map.onPause()
    }
}
```

```xml
<!-- res/layout/activity_main.xml -->
<org.osmdroid.views.MapView
    android:id="@+id/map"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
```

## When to Use This Skill

- Adding a map to an Android app
- Showing markers, routes, or polygons on a map
- GPS tracking on a map
- Offline map implementation
- Jetpack Compose map integration
- Field data collection apps
- ISP/telecom infrastructure maps
- Delivery tracking apps

## Key Rules

1. **Call Configuration before setContentView** — `Configuration.getInstance().load()` must be called before inflating layout.
2. **onResume/onPause are MANDATORY** — Call `map.onResume()` and `map.onPause()` for compass and location overlays.
3. **Call invalidate() after adding overlays** — Always call `map.invalidate()` after modifying overlays.
4. **User-Agent auto-set** — osmdroid sets HTTP User-Agent to your app's package name automatically.

## Common Patterns

### Markers

```kotlin
val marker = Marker(map)
marker.position = GeoPoint(lat, lng)
marker.title = "Client Name"
marker.snippet = "Plan: 50Mbps"
marker.icon = ContextCompat.getDrawable(this, R.drawable.ic_pin)
map.overlays.add(marker)
map.invalidate()
```

### Routes

```kotlin
val polyline = Polyline()
polyline.setPoints(listOf(
    GeoPoint(-12.0464, -77.0428),
    GeoPoint(-12.0500, -77.0460),
))
polyline.outlinePaint.color = Color.BLUE
polyline.outlinePaint.strokeWidth = 4f
map.overlays.add(polyline)
map.invalidate()
```

### GPS Location

```kotlin
val locationOverlay = MyLocationNewOverlay(GpsMyLocationProvider(this), map)
locationOverlay.enableMyLocation()
locationOverlay.enableFollowLocation()
map.overlays.add(locationOverlay)
map.invalidate()
```

## References

- `references/osmdroid-setup.md` — Complete setup, configuration, markers, overlays
- `references/osmdroid-advanced.md` — Routing, offline, Compose, GPX tracking
- `examples/MainActivity.kt` — Minimal working example
- `examples/FieldTechMap.kt` — Field technician map with markers and routes
