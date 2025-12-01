package com.season.app.season_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "season_app/maps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchGoogleMaps" -> {
                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")
                    if (latitude != null && longitude != null) {
                        launchGoogleMaps(latitude, longitude, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Latitude and longitude are required", null)
                    }
                }
                "launchMapsIntent" -> {
                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")
                    if (latitude != null && longitude != null) {
                        launchMapsIntent(latitude, longitude, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Latitude and longitude are required", null)
                    }
                }
                "launchUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        launchUrl(url, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "URL is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun launchGoogleMaps(latitude: Double, longitude: Double, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse("geo:$latitude,$longitude?q=$latitude,$longitude")
            val intent = Intent(Intent.ACTION_VIEW, uri)
            intent.setPackage("com.google.android.apps.maps")
            
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                result.success("Google Maps launched successfully")
            } else {
                result.error("APP_NOT_FOUND", "Google Maps app not found", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Failed to launch Google Maps: ${e.message}", null)
        }
    }

    private fun launchMapsIntent(latitude: Double, longitude: Double, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse("geo:$latitude,$longitude?q=$latitude,$longitude")
            val intent = Intent(Intent.ACTION_VIEW, uri)
            
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                result.success("Maps intent launched successfully")
            } else {
                result.error("NO_MAPS_APP", "No maps app found", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Failed to launch maps: ${e.message}", null)
        }
    }

    private fun launchUrl(url: String, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(url)
            val intent = Intent(Intent.ACTION_VIEW, uri)
            
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                result.success("URL launched successfully")
            } else {
                result.error("NO_BROWSER", "No browser found", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Failed to launch URL: ${e.message}", null)
        }
    }
}
