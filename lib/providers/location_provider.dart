import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location.dart';
import '../constants/app_constants.dart';

class LocationProvider extends ChangeNotifier {
  UserLocation? _currentLocation;
  QiblaDirection? _qiblaDirection;
  bool _isLoading = false;
  String? _error;
  bool _permissionGranted = false;
  
  UserLocation? get currentLocation => _currentLocation;
  QiblaDirection? get qiblaDirection => _qiblaDirection;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get permissionGranted => _permissionGranted;
  
  LocationProvider() {
    _loadSavedLocation();
    // Try to get current location if not available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasLocation) {
        getCurrentLocation();
      }
    });
  }
  
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(AppConstants.userLocationKey);
      final qiblaJson = prefs.getString(AppConstants.qiblaDirectionKey);
      
      if (locationJson != null) {
        _currentLocation = UserLocation.fromJson(json.decode(locationJson));
      }
      
      if (qiblaJson != null) {
        _qiblaDirection = QiblaDirection.fromJson(json.decode(qiblaJson));
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load saved location: $e';
    }
  }
  
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled. Please enable location services.';
        notifyListeners();
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permission denied. Please grant location access.';
          notifyListeners();
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permission permanently denied. Please enable in device settings.';
        notifyListeners();
        return false;
      }
      
      _permissionGranted = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to request location permission: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check location permissions first
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permission denied. Please allow location access in your browser and click the location icon in the address bar.';
          _useDefaultLocation();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permission permanently denied. Please enable location in browser settings.';
        _useDefaultLocation();
        return;
      }
      
      // Try to get current position with multiple strategies
      Position? position;
      
      // Strategy 1: High accuracy with longer timeout for web
      try {
        debugPrint('Attempting to get high accuracy location...');
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        );
        debugPrint('High accuracy location obtained: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        debugPrint('High accuracy failed: $e');
        
        // Strategy 2: Medium accuracy
        try {
          debugPrint('Trying medium accuracy location...');
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 15),
          );
          debugPrint('Medium accuracy location obtained: ${position.latitude}, ${position.longitude}');
        } catch (e2) {
          debugPrint('Medium accuracy failed: $e2');
          
          // Strategy 3: Low accuracy
          try {
            debugPrint('Trying low accuracy location...');
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 10),
            );
            debugPrint('Low accuracy location obtained: ${position.latitude}, ${position.longitude}');
          } catch (e3) {
            debugPrint('Low accuracy failed: $e3');
            
            // Strategy 4: Last known position
            try {
              debugPrint('Trying last known position...');
              position = await Geolocator.getLastKnownPosition();
              if (position != null) {
                debugPrint('Last known position obtained: ${position.latitude}, ${position.longitude}');
              }
            } catch (e4) {
              debugPrint('Last known position failed: $e4');
            }
          }
        }
      }
      
      if (position != null) {
        await _processLocationData(position);
      } else {
        _error = 'Unable to get your location. Please enable location services in your browser.';
        _useDefaultLocation();
      }
      
    } catch (e) {
      _error = 'Failed to get location: $e. Using default location.';
      debugPrint('Location error: $e');
      _useDefaultLocation();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _useDefaultLocation() {
    debugPrint('Using default location due to location access failure');
    _currentLocation = UserLocation(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      city: AppConstants.defaultCity,
      country: AppConstants.defaultCountry,
      timezone: 'Asia/Riyadh',
    );
    _permissionGranted = false; // Set to false to show this is default
    if (_error == null) {
      _error = 'Unable to detect your location. Showing default location (Mecca). Please enable location access for accurate prayer times.';
    }
    _saveLocation();
    calculateQiblaDirection();
    debugPrint('Default location set: ${_currentLocation!.city}, ${_currentLocation!.country}');
  }
  
  Future<void> _processLocationData(Position position) async {
    try {
      debugPrint('Processing location data: ${position.latitude}, ${position.longitude}');
      
      String city = 'Unknown';
      String country = 'Unknown';
      
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          debugPrint('Placemark found: ${placemark.toString()}');
          
          // Try different fields for city
          city = placemark.locality ?? 
                 placemark.subAdministrativeArea ?? 
                 placemark.administrativeArea ?? 
                 placemark.subLocality ?? 
                 'Unknown';
                 
          // Get country
          country = placemark.country ?? 'Unknown';
          
          debugPrint('Location resolved: $city, $country');
        } else {
          debugPrint('No placemarks found for coordinates');
        }
      } catch (e) {
        debugPrint('Geocoding failed: $e. Using coordinates only.');
        // Use coordinates to approximate location
        if (position.latitude >= 17.0 && position.latitude <= 19.0 && 
            position.longitude >= 78.0 && position.longitude <= 80.0) {
          city = 'Hyderabad';
          country = 'India';
        }
      }
      
      _currentLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        country: country,
        timezone: await _getTimezone(position.latitude, position.longitude),
      );
      
      _permissionGranted = true;
      _error = null; // Clear any previous errors
      await _saveLocation();
      await calculateQiblaDirection();
      
      debugPrint('Location successfully processed: ${_currentLocation!.city}, ${_currentLocation!.country}');
    } catch (e) {
      debugPrint('Error processing location data: $e');
      _useDefaultLocation();
    }
  }
  
  Future<void> setManualLocation(double latitude, double longitude) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final placemark = placemarks.first;
      
      _currentLocation = UserLocation(
        latitude: latitude,
        longitude: longitude,
        city: placemark.locality ?? placemark.subAdministrativeArea ?? 'Unknown',
        country: placemark.country ?? 'Unknown',
        timezone: await _getTimezone(latitude, longitude),
      );
      
      await _saveLocation();
      await calculateQiblaDirection();
      
    } catch (e) {
      _error = 'Failed to set manual location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> calculateQiblaDirection() async {
    if (_currentLocation == null) {
      _error = 'Location not available for Qibla calculation';
      notifyListeners();
      return;
    }
    
    try {
      // Kaaba coordinates
      const kaabaLat = 21.4225;
      const kaabaLng = 39.8262;
      
      final userLat = _currentLocation!.latitude;
      final userLng = _currentLocation!.longitude;
      
      // Calculate bearing to Kaaba
      final bearing = Geolocator.bearingBetween(
        userLat,
        userLng,
        kaabaLat,
        kaabaLng,
      );
      
      // Calculate distance to Kaaba
      final distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        kaabaLat,
        kaabaLng,
      );
      
      // Normalize bearing to 0-360
      final normalizedBearing = (bearing + 360) % 360;
      
      _qiblaDirection = QiblaDirection(
        direction: normalizedBearing,
        distance: distance,
        userLocation: _currentLocation!,
        calculatedAt: DateTime.now(),
      );
      
      await _saveQiblaDirection();
      _error = null; // Clear any previous errors
      notifyListeners();
      
      debugPrint('Qibla direction calculated: ${normalizedBearing.toStringAsFixed(1)}°');
      
    } catch (e) {
      _error = 'Failed to calculate Qibla direction: $e';
      debugPrint('Qibla calculation error: $e');
      notifyListeners();
    }
  }
  
  Future<void> _saveLocation() async {
    if (_currentLocation == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userLocationKey,
        json.encode(_currentLocation!.toJson()),
      );
    } catch (e) {
      debugPrint('Failed to save location: $e');
    }
  }
  
  Future<void> _saveQiblaDirection() async {
    if (_qiblaDirection == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.qiblaDirectionKey,
        json.encode(_qiblaDirection!.toJson()),
      );
    } catch (e) {
      debugPrint('Failed to save Qibla direction: $e');
    }
  }
  
  Future<String> _getTimezone(double latitude, double longitude) async {
    // Simplified timezone detection based on coordinates
    // In a production app, you might use a timezone API
    
    // India timezone
    if (latitude >= 6.0 && latitude <= 37.0 && longitude >= 68.0 && longitude <= 97.0) {
      return 'Asia/Kolkata';
    }
    
    // Saudi Arabia timezone
    if (latitude >= 16.0 && latitude <= 32.0 && longitude >= 34.0 && longitude <= 55.0) {
      return 'Asia/Riyadh';
    }
    
    // Pakistan timezone
    if (latitude >= 23.0 && latitude <= 37.0 && longitude >= 60.0 && longitude <= 77.0) {
      return 'Asia/Karachi';
    }
    
    // Bangladesh timezone
    if (latitude >= 20.0 && latitude <= 27.0 && longitude >= 88.0 && longitude <= 93.0) {
      return 'Asia/Dhaka';
    }
    
    // Default to UTC for other locations
    return 'UTC';
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  bool get hasLocation => _currentLocation != null;
  
  String get locationString {
    if (_currentLocation == null) return 'Location not set';
    return '${_currentLocation!.city}, ${_currentLocation!.country}';
  }
}