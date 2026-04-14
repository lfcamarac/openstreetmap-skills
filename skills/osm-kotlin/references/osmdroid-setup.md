# osmdroid — Complete Setup, Markers, Overlays

## Project Setup

### build.gradle (app level)

```gradle
dependencies {
    // Core
    implementation 'org.osmdroid:osmdroid-android:6.1.18'
    // Optional modules
    implementation 'org.osmdroid:osmdroid-geopackage:6.1.18'
    implementation 'org.osmdroid:osmdroid-wms:6.1.18'
    implementation 'org.osmdroid:osmdroid-mapsforge:6.1.18'
}
```

### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### ProGuard

```proguard
-keep class org.osmdroid.** { *; }
-dontwarn org.osmdroid.**
```

## Basic Activity

```kotlin
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.views.MapView

class MainActivity : AppCompatActivity() {
    private lateinit var map: MapView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // MUST be called BEFORE setContentView
        Configuration.getInstance().load(
            applicationContext,
            android.preference.PreferenceManager.getDefaultSharedPreferences(applicationContext)
        )

        setContentView(R.layout.activity_main)
        map = findViewById(R.id.map)

        map.setTileSource(TileSourceFactory.MAPNIK)
        map.controller.setZoom(13.0)
        map.controller.setCenter(org.osmdroid.util.GeoPoint(-12.0464, -77.0428))
        map.setMultiTouchControls(true)
        map.zoomController.setVisibility(
            org.osmdroid.views.CustomZoomButtonsController.Visibility.SHOW_AND_FADEOUT)
    }

    override fun onResume() {
        super.onResume()
        map.onResume()   // Required
    }

    override fun onPause() {
        super.onPause()
        map.onPause()    // Required
    }
}
```

## Markers

### Simple Marker

```kotlin
val marker = Marker(map)
marker.position = GeoPoint(-12.0464, -77.0428)
marker.setAnchor(Marker.ANCHOR_BOTTOM, Marker.ANCHOR_CENTER)
marker.title = "Client Name"
marker.snippet = "Plan: 50Mbps"
marker.icon = ContextCompat.getDrawable(this, R.drawable.ic_pin)
map.overlays.add(marker)
map.invalidate()
```

### Custom Icon Marker

```kotlin
val marker = Marker(map)
marker.position = GeoPoint(lat, lng)
marker.icon = ContextCompat.getDrawable(this, R.drawable.ic_antena)
marker.setAnchor(Marker.ANCHOR_BOTTOM, Marker.ANCHOR_CENTER)
marker.rotation = 45f  // For directional antennas
map.overlays.add(marker)
map.invalidate()
```

### Custom InfoWindow

```kotlin
// 1. Create layout res/layout/info_window.xml
// 2. Create class
class ClientInfoWindow(mapView: MapView) : InfoWindow(R.layout.info_window, mapView) {
    override fun onOpen(item: Any?) {
        val marker = item as Marker
        mView.findViewById<TextView>(R.id.title).text = marker.title
        mView.findViewById<TextView>(R.id.snippet).text = marker.snippet
    }
    override fun onClose() {}
}

// 3. Use
marker.infoWindow = ClientInfoWindow(map)
```

## Polylines

```kotlin
val polyline = Polyline()
polyline.setPoints(listOf(
    GeoPoint(-12.0464, -77.0428),
    GeoPoint(-12.0470, -77.0435),
    GeoPoint(-12.0480, -77.0440),
))
polyline.outlinePaint.color = Color.RED
polyline.outlinePaint.strokeWidth = 4f
polyline.setOnClickListener { _, _, _ -> true }
map.overlays.add(polyline)
map.invalidate()
```

## Polygons

```kotlin
val polygon = Polygon()
polygon.points = arrayListOf(
    GeoPoint(-12.04, -77.04),
    GeoPoint(-12.05, -77.04),
    GeoPoint(-12.05, -77.05),
    GeoPoint(-12.04, -77.05),
    GeoPoint(-12.04, -77.04),  // Close polygon
)
polygon.fillPaint.color = Color.argb(50, 0, 100, 255)
polygon.outlinePaint.color = Color.BLUE
polygon.outlinePaint.strokeWidth = 2f
map.overlays.add(polygon)
map.invalidate()
```

## Fast Overlay (>100k points)

```kotlin
val points = clients.map { c ->
    SimplePoint(c.lat, c.lng, c.id.toDouble())
}
val pointTheme = SimplePointTheme(points, true)

val symbolizer = SimplePointSymbolizer().apply {
    radius = 4; color = Color.GREEN; strokeWidth = 1; strokeColor = Color.DKGRAY
}
val options = SimpleFastPointOverlayOptions.getDefaultStyle()
    .setAlgorithm(SimpleFastPointOverlayOptions.RenderingAlgorithm.MAXIMUM_OPTIMIZATION)

val fastOverlay = SimpleFastPointOverlay(pointTheme, symbolizer, options)
map.overlays.add(fastOverlay)
map.invalidate()
```

## GPS Location

```kotlin
val locationOverlay = MyLocationNewOverlay(GpsMyLocationProvider(this), map)
locationOverlay.enableMyLocation()
locationOverlay.enableFollowLocation()
map.overlays.add(locationOverlay)
map.invalidate()

// Get current position
val current = locationOverlay.myLocation
```

## Scale Bar + Compass

```kotlin
map.overlays.add(ScaleBarOverlay(map))
val compass = CompassOverlay(this, map)
compass.enableCompass()
map.overlays.add(compass)
map.invalidate()
```

## Folder Overlay (group overlays)

```kotlin
val folder = FolderOverlay()
folder.name = "Infrastructure"

// Add markers, polylines, etc.
folder.add(marker1)
folder.add(polyline1)

map.overlays.add(folder)
map.invalidate()
```

## Runtime Permissions

```kotlin
private val REQUEST_CODE = 1

private fun checkPermissions() {
    if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
        != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(this,
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), REQUEST_CODE)
    } else {
        locationOverlay.enableMyLocation()
    }
}

override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    if (requestCode == REQUEST_CODE && grantResults.isNotEmpty()
        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        locationOverlay.enableMyLocation()
    }
}
```

## Tile Sources

```kotlin
map.setTileSource(TileSourceFactory.MAPNIK)           // Default
map.setTileSource(TileSourceFactory.CYCLEMAP)         // Cycle map
map.setTileSource(TileSourceFactory.OpenTopo)         // Topographic
map.setTileSource(TileSourceFactory.CartodbPositron)  // Light
map.setTileSource(TileSourceFactory.CartodbDark)      // Dark

// Custom tile server
val custom = XYTileSource("Custom", 0, 19, 256, ".png",
    arrayOf("https://tiles.miempresa.com/"))
map.setTileSource(custom)
```
