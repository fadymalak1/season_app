import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestPermissions() async {
    // Request location permission
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
      return false;
    }
    
    return false;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0, // No distance filter - we'll use time interval instead
      timeLimit: const Duration(seconds: 5), // Update every 5 seconds
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  static Future<double> getDistanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}

