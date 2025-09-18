import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/hijri_calendar.dart';
import '../constants/app_constants.dart';
import '../data/islamic_events_data.dart';

class IslamicCalendarProvider extends ChangeNotifier {
  HijriDate? _currentHijriDate;
  DateTime _selectedDate = DateTime.now();
  List<IslamicEvent> _events = [];
  List<FastingDay> _fastingDays = [];
  List<MonthInfo> _months = [];
  bool _isLoading = false;
  String? _error;
  Map<String, HijriDate> _hijriCache = {};

  // Getters
  HijriDate? get currentHijriDate => _currentHijriDate;
  DateTime get selectedDate => _selectedDate;
  List<IslamicEvent> get events => _events;
  List<FastingDay> get fastingDays => _fastingDays;
  List<MonthInfo> get months => _months;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, HijriDate> get hijriCache => _hijriCache;

  IslamicCalendarProvider() {
    _loadHijriMonths();
    _loadIslamicEvents();
    _loadFastingDays();
    _loadCachedData();
    _getCurrentHijriDate();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedHijri = prefs.getString('hijri_cache');
      if (cachedHijri != null) {
        final Map<String, dynamic> cacheData = json.decode(cachedHijri);
        _hijriCache = cacheData.map((key, value) => 
          MapEntry(key, HijriDate.fromJson(value)));
      }
    } catch (e) {
      debugPrint('Error loading cached Hijri data: $e');
    }
  }

  Future<void> _saveCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = _hijriCache.map((key, value) => 
        MapEntry(key, value.toJson()));
      await prefs.setString('hijri_cache', json.encode(cacheData));
    } catch (e) {
      debugPrint('Error saving Hijri cache: $e');
    }
  }

  Future<void> _getCurrentHijriDate() async {
    await getHijriDate(DateTime.now());
  }

  Future<void> getHijriDate(DateTime gregorianDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dateKey = '${gregorianDate.year}-${gregorianDate.month}-${gregorianDate.day}';
      
      // Check cache first
      if (_hijriCache.containsKey(dateKey)) {
        _currentHijriDate = _hijriCache[dateKey];
        _selectedDate = gregorianDate;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to fetch from API
      try {
        await _fetchHijriFromAPI(gregorianDate);
      } catch (e) {
        // Fallback to local calculation
        await _calculateHijriLocally(gregorianDate);
      }

      _selectedDate = gregorianDate;
      
      // Cache the result
      if (_currentHijriDate != null) {
        _hijriCache[dateKey] = _currentHijriDate!;
        await _saveCachedData();
      }

    } catch (e) {
      _error = 'Failed to get Hijri date: $e';
      debugPrint('Hijri date error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchHijriFromAPI(DateTime gregorianDate) async {
    final formattedDate = '${gregorianDate.day.toString().padLeft(2, '0')}-'
        '${gregorianDate.month.toString().padLeft(2, '0')}-'
        '${gregorianDate.year}';
    
    final response = await http.get(
      Uri.parse('https://api.aladhan.com/v1/gToH/$formattedDate'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 200 && data['data'] != null) {
        final hijriData = data['data']['hijri'];
        
        _currentHijriDate = HijriDate(
          day: int.parse(hijriData['day']),
          month: int.parse(hijriData['month']['number']),
          year: int.parse(hijriData['year']),
          monthName: hijriData['month']['en'],
          dayOfWeek: hijriData['weekday']['en'],
          gregorianDate: gregorianDate,
          events: _getEventsForDate(gregorianDate),
          isHoliday: _isHoliday(gregorianDate),
          isFasting: _isFastingDay(gregorianDate),
        );
        
        debugPrint('Hijri date fetched from API: ${_currentHijriDate!.formattedDate}');
        return;
      }
    }
    
    throw 'API response invalid';
  }

  Future<void> _calculateHijriLocally(DateTime gregorianDate) async {
    // Simple Hijri calculation (approximate)
    // This is a basic calculation - in production, use a proper Hijri library
    
    final hijriEpoch = DateTime(622, 7, 16); // Approximate Hijri epoch
    final daysSinceEpoch = gregorianDate.difference(hijriEpoch).inDays;
    
    // Average Hijri year is 354.37 days
    final hijriYear = (daysSinceEpoch / 354.37).floor() + 1;
    final dayOfYear = daysSinceEpoch % 354.37;
    
    // Calculate month and day (simplified)
    int month = 1;
    int day = dayOfYear.floor();
    
    const monthDays = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];
    
    for (int i = 0; i < 12; i++) {
      if (day <= monthDays[i]) {
        month = i + 1;
        break;
      }
      day -= monthDays[i];
    }
    
    if (day <= 0) day = 1;
    
    _currentHijriDate = HijriDate(
      day: day,
      month: month,
      year: hijriYear,
      monthName: _getMonthName(month),
      dayOfWeek: _getDayOfWeek(gregorianDate),
      gregorianDate: gregorianDate,
      events: _getEventsForDate(gregorianDate),
      isHoliday: _isHoliday(gregorianDate),
      isFasting: _isFastingDay(gregorianDate),
    );
    
    debugPrint('Hijri date calculated locally: ${_currentHijriDate!.formattedDate}');
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Muharram', 'Safar', 'Rabi\' al-awwal', 'Rabi\' al-thani',
      'Jumada al-awwal', 'Jumada al-thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
    
    return month >= 1 && month <= 12 ? monthNames[month - 1] : 'Unknown';
  }

  String _getDayOfWeek(DateTime date) {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return dayNames[date.weekday - 1];
  }

  List<IslamicEvent> _getEventsForDate(DateTime date) {
    return _events.where((event) {
      if (event.isRecurring) {
        // Check if the date matches recurring pattern
        return _checkRecurringEvent(event, date);
      } else {
        // Check if date is within event range
        if (event.endDate != null) {
          return date.isAfter(event.startDate.subtract(const Duration(days: 1))) &&
                 date.isBefore(event.endDate!.add(const Duration(days: 1)));
        } else {
          return _isSameDay(date, event.startDate);
        }
      }
    }).toList();
  }

  bool _checkRecurringEvent(IslamicEvent event, DateTime date) {
    // Simple recurring event check - could be enhanced
    return date.month == event.startDate.month && 
           date.day == event.startDate.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isHoliday(DateTime date) {
    final events = _getEventsForDate(date);
    return events.any((event) => 
      event.type == EventType.religious || 
      event.type == EventType.celebration);
  }

  bool _isFastingDay(DateTime date) {
    return _fastingDays.any((fasting) => _isSameDay(date, fasting.date));
  }

  void _loadHijriMonths() {
    _months = IslamicEventsData.getHijriMonths();
    notifyListeners();
  }

  void _loadIslamicEvents() {
    _events = IslamicEventsData.getIslamicEvents();
    notifyListeners();
  }

  void _loadFastingDays() {
    _fastingDays = IslamicEventsData.getFastingDays();
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    await getHijriDate(date);
  }

  List<IslamicEvent> getEventsForMonth(int year, int month) {
    return _events.where((event) {
      final eventDate = event.startDate;
      return eventDate.year == year && eventDate.month == month;
    }).toList();
  }

  List<FastingDay> getFastingDaysForMonth(int year, int month) {
    return _fastingDays.where((fasting) {
      final fastingDate = fasting.date;
      return fastingDate.year == year && fastingDate.month == month;
    }).toList();
  }

  Future<void> addPersonalEvent(IslamicEvent event) async {
    _events.add(event);
    await _savePersonalEvents();
    notifyListeners();
  }

  Future<void> removePersonalEvent(String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
    await _savePersonalEvents();
    notifyListeners();
  }

  Future<void> _savePersonalEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final personalEvents = _events.where((e) => e.type == EventType.personal).toList();
      final eventsJson = personalEvents.map((e) => e.toJson()).toList();
      await prefs.setString('personal_events', json.encode(eventsJson));
    } catch (e) {
      debugPrint('Error saving personal events: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  MonthInfo? getMonthInfo(int monthNumber) {
    return _months.firstWhere(
      (month) => month.monthNumber == monthNumber,
      orElse: () => const MonthInfo(
        monthNumber: 1,
        arabicName: '',
        englishName: 'Unknown',
        description: '',
        days: 30,
      ),
    );
  }
}