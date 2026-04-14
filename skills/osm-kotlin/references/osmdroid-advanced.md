# osmdroid — Routing, Offline, Compose, GPX

## Routing with OSRM

```kotlin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import org.osmdroid.util.GeoPoint
import java.net.URL

data class RouteResult(
    val points: List<GeoPoint>,
    val distanceMeters: Double,
    val durationSeconds: Double
)

suspend fun getOSRMRoute(
    startLat: Double, startLon: Double,
    endLat: Double, endLon: Double
): RouteResult? = withContext(Dispatchers.IO) {
    try {
        val url = "https://router.project-osrm.org/route/v1/driving/" +
            "$startLon,$startLat;$endLon,$endLat" +
            "?overview=full&geometries=geojson&steps=true"

        val response = URL(url).readText()
        val json = JSONObject(response)
        val route = json.getJSONArray("routes").getJSONObject(0)
        val geometry = route.getJSONObject("geometry")
        val coordinates = geometry.getJSONArray("coordinates")

        val points = mutableListOf<GeoPoint>()
        for (i in 0 until coordinates.length()) {
            val coord = coordinates.getJSONArray(i)
            points.add(GeoPoint(coord.getDouble(1), coord.getDouble(0)))
        }

        RouteResult(
            points = points,
            distanceMeters = route.getDouble("distance"),
            durationSeconds = route.getDouble("duration")
        )
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

// Usage
lifecycleScope.launch {
    val route = getOSRMRoute(-12.0464, -77.0428, -12.0500, -77.0460)
    if (route != null) {
        val polyline = Polyline()
        polyline.setPoints(route.points)
        polyline.outlinePaint.color = Color.BLUE
        polyline.outlinePaint.strokeWidth = 6f
        map.overlays.add(polyline)
        map.invalidate()

        Toast.makeText(this@MainActivity,
            "Distance: ${"%.1f".format(route.distanceMeters / 1000)} km",
            Toast.LENGTH_LONG).show()
    }
}
```

## GPX Track Recording

```kotlin
val trackPoints = mutableListOf<GeoPoint>()

fun addTrackPoint(location: android.location.Location) {
    val point = GeoPoint(location.latitude, location.longitude)
    trackPoints.add(point)

    // Draw on map
    val trackLine = Polyline()
    trackLine.setPoints(trackPoints)
    trackLine.outlinePaint.color = Color.BLUE
    trackLine.outlinePaint.strokeWidth = 4f

    // Remove previous track
    map.overlays.removeIf { it is Polyline && it.outlinePaint.color == Color.BLUE }
    map.overlays.add(trackLine)
    map.invalidate()
}

// Export to GPX
fun exportTrackToGPX(filePath: String) {
    val file = File(filePath)
    FileWriter(file).use { writer ->
        writer.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        writer.write("<gpx version=\"1.1\">\n<trk><trkseg>\n")
        trackPoints.forEach { point ->
            writer.write("  <trkpt lat=\"${point.latitude}\" lon=\"${point.longitude}\"/>\n")
        }
        writer.write("</trkseg></trk></gpx>\n")
    }
}
```

## Offline Maps

```kotlin
import org.osmdroid.tileprovider.modules.MapTileFileArchiveProvider

fun setupOfflineMap(map: MapView, archivePath: String) {
    val file = File(archivePath)
    val tileProvider = MapTileFileArchiveProvider(
        map.context,
        TileSourceFactory.MAPNIK,
        arrayOf(file)
    )
    map.setTileProvider(tileProvider)
    map.setTileSource(TileSourceFactory.MAPNIK)
    map.invalidate()
}
```

### GeoPackage Offline

```kotlin
import org.osmdroid.geopackage.GeoPackageOverlay

fun loadGeoPackage(map: MapView, geopackagePath: String) {
    val overlay = GeoPackageOverlay(geopackagePath)
    map.overlays.add(overlay)
    map.invalidate()
}
```

## Jetpack Compose Integration

```kotlin
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import org.osmdroid.views.MapView
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint

@Composable
fun OSMMapView(
    modifier: Modifier = Modifier,
    initialLat: Double = -12.0464,
    initialLon: Double = -77.0428,
    initialZoom: Double = 13.0,
    onMapReady: (MapView) -> Unit = {}
) {
    AndroidView(
        modifier = modifier,
        factory = { context ->
            Configuration.getInstance().load(
                context,
                android.preference.PreferenceManager.getDefaultSharedPreferences(context)
            )
            MapView(context).apply {
                setTileSource(TileSourceFactory.MAPNIK)
                setMultiTouchControls(true)
                controller.setZoom(initialZoom)
                controller.setCenter(GeoPoint(initialLat, initialLon))
                onMapReady(this)
            }
        },
        update = { mapView ->
            // Update when parameters change
        }
    )
}

// Usage in Compose
@Composable
fun MapScreen() {
    OSMMapView(
        modifier = Modifier.fillMaxSize(),
        onMapReady = { map ->
            // Add markers, routes, etc.
            val marker = Marker(map)
            marker.position = GeoPoint(-12.0464, -77.0428)
            map.overlays.add(marker)
            map.invalidate()
        }
    )
}
```

## KML Loading

```kotlin
// Requires osmdroid bonus pack or external library
import org.osmdroid.bonuspack.kml.KmlDocument

fun loadKml(map: MapView, kmlPath: String) {
    val kmlDocument = KmlDocument()
    if (kmlDocument.parseKMLFile(File(kmlPath))) {
        map.overlays.add(kmlDocument.mKmlRoot.buildOverlay(map, null, null, kmlDocument))
        map.invalidate()
    }
}
```

## Map Click Listener

```kotlin
map.setLongClickable(true)
map.overlayManager.eventsOverlay?.setLongPressable { event ->
    val geoPoint = map.projection.fromPixels(
        event.x.toInt(), event.y.toInt()
    ) as GeoPoint
    // Handle long press at geoPoint
    true
}
```

## Distance Calculations

```kotlin
import org.osmdroid.util.GeoPoint

val distance = GeoPoint.distanceBetween(
    lat1, lon1, lat2, lon2
)  // Returns meters

val bearing = GeoPoint.bearing(
    GeoPoint(lat1, lon1),
    GeoPoint(lat2, lon2)
)  // Returns degrees
```
