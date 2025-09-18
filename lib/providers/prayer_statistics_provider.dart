import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/prayer_statistics.dart';

class PrayerStatisticsProvider extends ChangeNotifier {
  List<PrayerRecord> _prayerRecords = [];
  PrayerStatistics? _currentStatistics;
  PrayerStreak? _currentStreak;
  PrayerStreak? _longestStreak;
  WeeklyProgress? _weeklyProgress;
  bool _isLoading = false;
  String? _error;
  
  // Current period for statistics
  StatisticsPeriod _currentPeriod = StatisticsPeriod.thisMonth;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Getters
  List<PrayerRecord> get prayerRecords => _prayerRecords;
  PrayerStatistics? get currentStatistics => _currentStatistics;
  PrayerStreak? get currentStreak => _currentStreak;
  PrayerStreak? get longestStreak => _longestStreak;
  WeeklyProgress? get weeklyProgress => _weeklyProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  StatisticsPeriod get currentPeriod => _currentPeriod;

  PrayerStatisticsProvider() {
    _loadPrayerRecords();
  }

  Future<void> _loadPrayerRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList('prayer_records');
      
      if (recordsJson != null) {
        _prayerRecords = recordsJson
            .map((json) => PrayerRecord.fromJson(jsonDecode(json)))
            .toList();
      }
      
      await _calculateStatistics();
    } catch (e) {
      _error = 'Failed to load prayer records: $e';
      debugPrint('Error loading prayer records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _savePrayerRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = _prayerRecords
          .map((record) => jsonEncode(record.toJson()))
          .toList();
      await prefs.setStringList('prayer_records', recordsJson);
    } catch (e) {
      debugPrint('Error saving prayer records: $e');
    }
  }

  Future<void> addPrayerRecord(PrayerRecord record) async {
    // Check if record already exists for this prayer and date
    final existingIndex = _prayerRecords.indexWhere((r) => 
      r.prayerName == record.prayerName &&
      r.scheduledTime.day == record.scheduledTime.day &&
      r.scheduledTime.month == record.scheduledTime.month &&
      r.scheduledTime.year == record.scheduledTime.year
    );

    if (existingIndex != -1) {
      // Update existing record
      _prayerRecords[existingIndex] = record;
    } else {
      // Add new record
      _prayerRecords.add(record);
    }

    // Sort by scheduled time
    _prayerRecords.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    
    await _savePrayerRecords();
    await _calculateStatistics();
    notifyListeners();
  }

  Future<void> markPrayerCompleted(
    String prayerName,
    DateTime scheduledTime,
    {DateTime? actualTime, bool isJamaat = false, String? location, String? notes}
  ) async {
    final id = '${prayerName}_${scheduledTime.toIso8601String()}';
    final now = actualTime ?? DateTime.now();
    
    // Calculate timeliness
    final timeDiff = now.difference(scheduledTime).inMinutes;
    
    // Determine status based on timeliness
    PrayerStatus status;
    if (timeDiff <= -5) {
      status = PrayerStatus.early;
    } else if (timeDiff >= 5) {
      status = PrayerStatus.late;
    } else {
      status = PrayerStatus.onTime;
    }

    final record = PrayerRecord(
      id: id,
      prayerName: prayerName,
      scheduledTime: scheduledTime,
      actualTime: now,
      status: status,
      timeliness: timeDiff.toDouble(),
      location: location,
      isJamaat: isJamaat,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await addPrayerRecord(record);
  }

  Future<void> markPrayerMissed(String prayerName, DateTime scheduledTime) async {
    final id = '${prayerName}_${scheduledTime.toIso8601String()}';
    
    final record = PrayerRecord(
      id: id,
      prayerName: prayerName,
      scheduledTime: scheduledTime,
      status: PrayerStatus.missed,
      createdAt: DateTime.now(),
    );

    await addPrayerRecord(record);
  }

  Future<void> deletePrayerRecord(String recordId) async {
    _prayerRecords.removeWhere((record) => record.id == recordId);
    await _savePrayerRecords();
    await _calculateStatistics();
    notifyListeners();
  }

  Future<void> _calculateStatistics() async {
    if (_prayerRecords.isEmpty) {
      _currentStatistics = null;
      _currentStreak = null;
      _longestStreak = null;
      _weeklyProgress = null;
      return;
    }

    // Get date range for current period
    final dateRange = _getDateRangeForPeriod(_currentPeriod);
    
    // Filter records for current period
    final periodRecords = _prayerRecords.where((record) {
      return record.createdAt.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
             record.createdAt.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    // Calculate main statistics
    _currentStatistics = PrayerStatistics.fromRecords(
      periodRecords,
      dateRange.start,
      dateRange.end,
    );

    // Calculate streaks
    _currentStreak = PrayerStreak.fromRecords(_prayerRecords, StreakType.completion);
    _longestStreak = PrayerStreak.fromRecords(_prayerRecords, StreakType.consistency);

    // Calculate weekly progress
    final weekStart = _getWeekStart(DateTime.now());
    final weekRecords = _prayerRecords.where((record) {
      final weekEnd = weekStart.add(const Duration(days: 6));
      return record.createdAt.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             record.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    _weeklyProgress = WeeklyProgress.fromRecords(weekStart, weekRecords);
  }

  Future<void> setPeriod(StatisticsPeriod period) async {
    _currentPeriod = period;
    await _calculateStatistics();
    notifyListeners();
  }

  Future<void> setCustomPeriod(DateTime startDate, DateTime endDate) async {
    _currentPeriod = StatisticsPeriod.custom;
    _customStartDate = startDate;
    _customEndDate = endDate;
    await _calculateStatistics();
    notifyListeners();
  }

  DateRange _getDateRangeForPeriod(StatisticsPeriod period) {
    final now = DateTime.now();
    
    switch (period) {
      case StatisticsPeriod.today:
        final today = DateTime(now.year, now.month, now.day);
        return DateRange(today, today.add(const Duration(days: 1)));
        
      case StatisticsPeriod.thisWeek:
        final weekStart = _getWeekStart(now);
        return DateRange(weekStart, weekStart.add(const Duration(days: 7)));
        
      case StatisticsPeriod.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return DateRange(monthStart, nextMonth);
        
      case StatisticsPeriod.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        final nextYear = DateTime(now.year + 1, 1, 1);
        return DateRange(yearStart, nextYear);
        
      case StatisticsPeriod.allTime:
        final firstRecord = _prayerRecords.isNotEmpty 
            ? _prayerRecords.first.createdAt
            : now;
        return DateRange(firstRecord, now);
        
      case StatisticsPeriod.custom:
        return DateRange(
          _customStartDate ?? now,
          _customEndDate ?? now,
        );
    }
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday as week start
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  List<DailyPrayerStats> getDailyStatsForPeriod(StatisticsPeriod period) {
    final dateRange = _getDateRangeForPeriod(period);
    final dailyStats = <DailyPrayerStats>[];
    
    DateTime currentDate = dateRange.start;
    while (currentDate.isBefore(dateRange.end)) {
      final dayRecords = _prayerRecords.where((record) {
        return record.createdAt.year == currentDate.year &&
               record.createdAt.month == currentDate.month &&
               record.createdAt.day == currentDate.day;
      }).toList();
      
      dailyStats.add(DailyPrayerStats.fromRecords(currentDate, dayRecords));
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return dailyStats;
  }

  List<PrayerRecord> getRecordsForPrayer(String prayerName) {
    return _prayerRecords.where((record) => record.prayerName == prayerName).toList();
  }

  List<PrayerRecord> getRecordsForDate(DateTime date) {
    return _prayerRecords.where((record) {
      return record.createdAt.year == date.year &&
             record.createdAt.month == date.month &&
             record.createdAt.day == date.day;
    }).toList();
  }

  Map<String, double> getPrayerCompletionTrends(int days) {
    final trends = <String, double>{};
    const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    
    for (final prayer in prayerNames) {
      final prayerRecords = getRecordsForPrayer(prayer);
      final recentRecords = prayerRecords.where((record) {
        return record.createdAt.isAfter(
          DateTime.now().subtract(Duration(days: days))
        );
      }).toList();
      
      if (recentRecords.isNotEmpty) {
        final completed = recentRecords.where((r) => r.status == PrayerStatus.completed).length;
        trends[prayer] = (completed / recentRecords.length) * 100;
      } else {
        trends[prayer] = 0.0;
      }
    }
    
    return trends;
  }

  double getAverageTimeliness(String? prayerName) {
    List<PrayerRecord> records;
    
    if (prayerName != null) {
      records = getRecordsForPrayer(prayerName);
    } else {
      records = _prayerRecords;
    }
    
    final timelinessRecords = records.where((r) => r.timeliness != null).toList();
    
    if (timelinessRecords.isEmpty) return 0.0;
    
    final sum = timelinessRecords.map((r) => r.timeliness!).reduce((a, b) => a + b);
    return sum / timelinessRecords.length;
  }

  Future<void> clearAllRecords() async {
    _prayerRecords.clear();
    await _savePrayerRecords();
    await _calculateStatistics();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

enum StatisticsPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  allTime,
  custom,
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);
}