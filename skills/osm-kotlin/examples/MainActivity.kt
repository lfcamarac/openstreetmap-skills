// Example: Basic osmdroid map in Kotlin
// Create a new Android project and replace MainActivity

package com.example.osmdemo

import android.os.Bundle
import android.preference.PreferenceManager
import androidx.appcompat.app.AppCompatActivity
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

class MainActivity : AppCompatActivity() {
    private lateinit var map: MapView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // MUST be called before setContentView
        Configuration.getInstance().load(
            applicationContext,
            PreferenceManager.getDefaultSharedPreferences(applicationContext)
        )

        setContentView(R.layout.activity_main)
        map = findViewById(R.id.map)

        // Configure map
        map.setTileSource(TileSourceFactory.MAPNIK)
        map.controller.setZoom(15.0)
        map.controller.setCenter(GeoPoint(-12.0464, -77.0428))
        map.setMultiTouchControls(true)

        // Add markers
        addMarker(-12.0464, -77.0428, "Office", "Main office")
        addMarker(-12.0500, -77.0460, "Client", "50Mbps plan")

        // Add route
        addRoute()
    }

    private fun addMarker(lat: Double, lon: Double, title: String, snippet: String) {
        val marker = Marker(map)
        marker.position = GeoPoint(lat, lon)
        marker.setAnchor(Marker.ANCHOR_BOTTOM, Marker.ANCHOR_CENTER)
        marker.title = title
        marker.snippet = snippet
        map.overlays.add(marker)
        map.invalidate()
    }

    private fun addRoute() {
        import org.osmdroid.views.overlay.Polyline
        import android.graphics.Color

        val polyline = Polyline()
        polyline.setPoints(listOf(
            GeoPoint(-12.0464, -77.0428),
            GeoPoint(-12.0480, -77.0440),
            GeoPoint(-12.0500, -77.0460),
        ))
        polyline.outlinePaint.color = Color.BLUE
        polyline.outlinePaint.strokeWidth = 4f
        map.overlays.add(polyline)
        map.invalidate()
    }

    override fun onResume() {
        super.onResume()
        map.onResume()
    }

    override fun onPause() {
        super.onPause()
        map.onPause()
    }
}
