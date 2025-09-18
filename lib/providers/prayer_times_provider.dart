import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/prayer_times.dart';
import '../models/location.dart';
import '../constants/app_constants.dart';

class PrayerTimesProvider extends ChangeNotifier {
  PrayerTimes? _prayerTimes;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;
  
  PrayerTimes? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  
  PrayerTimesProvider() {
    _loadSavedPrayerTimes();
  }
  
  Future<void> _loadSavedPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayerTimesJson = prefs.getString(AppConstants.prayerTimesKey);
      
      if (prayerTimesJson != null) {
        final data = json.decode(prayerTimesJson);
        _prayerTimes = PrayerTimes.fromJson(data);
        _lastUpdated = DateTime.parse(data['lastUpdated'] ?? DateTime.now().toIso8601String());
        
        // Check if data is from today, if not, it might be outdated
        final today = DateTime.now();
        if (_prayerTimes != null && 
            _prayerTimes!.date.day != today.day ||
            _prayerTimes!.date.month != today.month ||
            _prayerTimes!.date.year != today.year) {
          // Data is outdated, will need to fetch new data
          _prayerTimes = null;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load saved prayer times: $e';
    }
  }
  
  Future<void> fetchPrayerTimes(
    UserLocation location, 
    int calculationMethod,
    {DateTime? date}
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final targetDate = date ?? DateTime.now();
      // Format date as DD-MM-YYYY with proper padding for Aladhan API
      final day = targetDate.day.toString().padLeft(2, '0');
      final month = targetDate.month.toString().padLeft(2, '0');
      final year = targetDate.year.toString();
      final dateStr = '$day-$month-$year';
      
      final url = Uri.parse(
        '${AppConstants.aladhanBaseUrl}/timings/$dateStr'
        '?latitude=${location.latitude}'
        '&longitude=${location.longitude}'
        '&method=$calculationMethod'
      );
      
      debugPrint('Fetching prayer times from: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 15), // Increased timeout
      );
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint('Prayer times API response: $responseBody');
        
        final data = json.decode(responseBody);
        
        if (data['code'] == 200 && data['status'] == 'OK') {
          try {
            _prayerTimes = PrayerTimes.fromJson(data['data']);
            _lastUpdated = DateTime.now();
            await _savePrayerTimes();
            debugPrint('Prayer times loaded successfully');
          } catch (e) {
            _error = 'Failed to parse prayer times data: $e';
            debugPrint('Parse error: $e');
          }
        } else {
          _error = 'API returned error: ${data['status'] ?? 'Unknown error'}';
          debugPrint('API error response: $data');
        }
      } else {
        _error = 'HTTP error: ${response.statusCode} - ${response.reasonPhrase}';
        debugPrint('HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _savePrayerTimes() async {
    if (_prayerTimes == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataToSave = {
        ..._prayerTimes!.toJson(),
        'lastUpdated': (_lastUpdated ?? DateTime.now()).toIso8601String(),
      };
      
      await prefs.setString(
        AppConstants.prayerTimesKey,
        json.encode(dataToSave),
      );
    } catch (e) {
      debugPrint('Failed to save prayer times: $e');
    }
  }
  
  Prayer? getNextPrayer() {
    return _prayerTimes?.getNextPrayer();
  }
  
  Duration getTimeUntilNextPrayer() {
    return _prayerTimes?.getTimeUntilNextPrayer() ?? Duration.zero;
  }
  
  String getTimeUntilNextPrayerFormatted() {
    final duration = getTimeUntilNextPrayer();
    
    if (duration == Duration.zero) {
      return '';
    }
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  List<Prayer> getTodaysPrayers() {
    return _prayerTimes?.prayerList ?? [];
  }
  
  bool isPrayerTime(String prayerName) {
    if (_prayerTimes == null) return false;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return currentTime == _prayerTimes!.fajr;
      case 'dhuhr':
        return currentTime == _prayerTimes!.dhuhr;
      case 'asr':
        return currentTime == _prayerTimes!.asr;
      case 'maghrib':
        return currentTime == _prayerTimes!.maghrib;
      case 'isha':
        return currentTime == _prayerTimes!.isha;
      default:
        return false;
    }
  }
  
  bool needsUpdate() {
    if (_prayerTimes == null) return true;
    
    final now = DateTime.now();
    return _prayerTimes!.date.day != now.day ||
           _prayerTimes!.date.month != now.month ||
           _prayerTimes!.date.year != now.year;
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  String get formattedHijriDate {
    return _prayerTimes?.hijriDate ?? '';
  }
  
  String get formattedGregorianDate {
    if (_prayerTimes == null) return '';
    
    final date = _prayerTimes!.date;
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}