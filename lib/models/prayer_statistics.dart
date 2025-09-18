import 'package:flutter/foundation.dart';

class PrayerRecord {
  final String id;
  final String prayerName;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final PrayerStatus status;
  final double? timeliness; // How early/late in minutes (positive = late, negative = early)
  final String? location;
  final bool isJamaat; // Prayed in congregation
  final String? notes;
  final DateTime createdAt;

  const PrayerRecord({
    required this.id,
    required this.prayerName,
    required this.scheduledTime,
    this.actualTime,
    required this.status,
    this.timeliness,
    this.location,
    this.isJamaat = false,
    this.notes,
    required this.createdAt,
  });

  factory PrayerRecord.fromJson(Map<String, dynamic> json) {
    return PrayerRecord(
      id: json['id'] ?? '',
      prayerName: json['prayerName'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime']),
      actualTime: json['actualTime'] != null 
          ? DateTime.parse(json['actualTime'])
          : null,
      status: PrayerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrayerStatus.missed,
      ),
      timeliness: json['timeliness']?.toDouble(),
      location: json['location'],
      isJamaat: json['isJamaat'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayerName': prayerName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
      'status': status.name,
      'timeliness': timeliness,
      'location': location,
      'isJamaat': isJamaat,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PrayerRecord copyWith({
    String? id,
    String? prayerName,
    DateTime? scheduledTime,
    DateTime? actualTime,
    PrayerStatus? status,
    double? timeliness,
    String? location,
    bool? isJamaat,
    String? notes,
    DateTime? createdAt,
  }) {
    return PrayerRecord(
      id: id ?? this.id,
      prayerName: prayerName ?? this.prayerName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      timeliness: timeliness ?? this.timeliness,
      location: location ?? this.location,
      isJamaat: isJamaat ?? this.isJamaat,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum PrayerStatus {
  completed,
  missed,
  late,
  onTime,
  early,
  pending,
}

class PrayerStatistics {
  final int totalPrayers;
  final int completedPrayers;
  final int missedPrayers;
  final int latePrayers;
  final int onTimePrayers;
  final int earlyPrayers;
  final int jamaatPrayers;
  final double completionRate;
  final double punctualityRate;
  final double jamaatRate;
  final Map<String, int> prayerCounts;
  final Map<String, double> prayerCompletionRates;
  final double averageTimeliness; // Average minutes early/late
  final DateTime periodStart;
  final DateTime periodEnd;

  const PrayerStatistics({
    required this.totalPrayers,
    required this.completedPrayers,
    required this.missedPrayers,
    required this.latePrayers,
    required this.onTimePrayers,
    required this.earlyPrayers,
    required this.jamaatPrayers,
    required this.completionRate,
    required this.punctualityRate,
    required this.jamaatRate,
    required this.prayerCounts,
    required this.prayerCompletionRates,
    required this.averageTimeliness,
    required this.periodStart,
    required this.periodEnd,
  });

  factory PrayerStatistics.fromRecords(
    List<PrayerRecord> records,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    if (records.isEmpty) {
      return PrayerStatistics.empty(periodStart, periodEnd);
    }

    final completed = records.where((r) => r.status == PrayerStatus.completed).length;
    final missed = records.where((r) => r.status == PrayerStatus.missed).length;
    final late = records.where((r) => r.status == PrayerStatus.late).length;
    final onTime = records.where((r) => r.status == PrayerStatus.onTime).length;
    final early = records.where((r) => r.status == PrayerStatus.early).length;
    final jamaat = records.where((r) => r.isJamaat).length;

    final total = records.length;
    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;
    final punctualityRate = total > 0 ? ((onTime + early) / total) * 100 : 0.0;
    final jamaatRate = total > 0 ? (jamaat / total) * 100 : 0.0;

    // Prayer counts by name
    final prayerCounts = <String, int>{};
    final prayerCompletionCounts = <String, int>{};
    
    for (final record in records) {
      prayerCounts[record.prayerName] = (prayerCounts[record.prayerName] ?? 0) + 1;
      if (record.status == PrayerStatus.completed) {
        prayerCompletionCounts[record.prayerName] = 
            (prayerCompletionCounts[record.prayerName] ?? 0) + 1;
      }
    }

    // Prayer completion rates
    final prayerCompletionRates = <String, double>{};
    for (final prayer in prayerCounts.keys) {
      final totalCount = prayerCounts[prayer]!;
      final completedCount = prayerCompletionCounts[prayer] ?? 0;
      prayerCompletionRates[prayer] = (completedCount / totalCount) * 100;
    }

    // Average timeliness
    final timelinessRecords = records.where((r) => r.timeliness != null).toList();
    final averageTimeliness = timelinessRecords.isNotEmpty
        ? timelinessRecords.map((r) => r.timeliness!).reduce((a, b) => a + b) / timelinessRecords.length
        : 0.0;

    return PrayerStatistics(
      totalPrayers: total,
      completedPrayers: completed,
      missedPrayers: missed,
      latePrayers: late,
      onTimePrayers: onTime,
      earlyPrayers: early,
      jamaatPrayers: jamaat,
      completionRate: completionRate,
      punctualityRate: punctualityRate,
      jamaatRate: jamaatRate,
      prayerCounts: prayerCounts,
      prayerCompletionRates: prayerCompletionRates,
      averageTimeliness: averageTimeliness,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  factory PrayerStatistics.empty(DateTime periodStart, DateTime periodEnd) {
    return PrayerStatistics(
      totalPrayers: 0,
      completedPrayers: 0,
      missedPrayers: 0,
      latePrayers: 0,
      onTimePrayers: 0,
      earlyPrayers: 0,
      jamaatPrayers: 0,
      completionRate: 0.0,
      punctualityRate: 0.0,
      jamaatRate: 0.0,
      prayerCounts: {},
      prayerCompletionRates: {},
      averageTimeliness: 0.0,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  String get periodDescription {
    final duration = periodEnd.difference(periodStart).inDays;
    if (duration <= 1) return 'Today';
    if (duration <= 7) return 'This Week';
    if (duration <= 31) return 'This Month';
    if (duration <= 365) return 'This Year';
    return 'All Time';
  }
}

class DailyPrayerStats {
  final DateTime date;
  final Map<String, PrayerRecord?> prayers;
  final int completedCount;
  final int totalCount;
  final double completionRate;

  const DailyPrayerStats({
    required this.date,
    required this.prayers,
    required this.completedCount,
    required this.totalCount,
    required this.completionRate,
  });

  factory DailyPrayerStats.fromRecords(
    DateTime date,
    List<PrayerRecord> dayRecords,
  ) {
    const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final prayers = <String, PrayerRecord?>{};
    
    for (final prayer in prayerNames) {
      prayers[prayer] = dayRecords
          .where((r) => r.prayerName == prayer)
          .isNotEmpty 
              ? dayRecords.firstWhere((r) => r.prayerName == prayer)
              : null;
    }

    final completed = prayers.values.where((r) => r?.status == PrayerStatus.completed).length;
    final total = prayerNames.length;
    final rate = total > 0 ? (completed / total) * 100 : 0.0;

    return DailyPrayerStats(
      date: date,
      prayers: prayers,
      completedCount: completed,
      totalCount: total,
      completionRate: rate,
    );
  }
}

class PrayerStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? streakStartDate;
  final DateTime? lastPrayerDate;
  final StreakType type;

  const PrayerStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.streakStartDate,
    this.lastPrayerDate,
    this.type = StreakType.completion,
  });

  factory PrayerStreak.fromRecords(
    List<PrayerRecord> records,
    StreakType type,
  ) {
    if (records.isEmpty) {
      return const PrayerStreak(
        currentStreak: 0,
        longestStreak: 0,
      );
    }

    // Sort records by date
    records.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? streakStart;
    DateTime? lastPrayerDate;

    // Group by date and calculate daily completion
    final dailyStats = <DateTime, DailyPrayerStats>{};
    
    for (final record in records) {
      final date = DateTime(
        record.createdAt.year,
        record.createdAt.month,
        record.createdAt.day,
      );
      
      if (!dailyStats.containsKey(date)) {
        final dayRecords = records.where((r) => 
          r.createdAt.year == date.year &&
          r.createdAt.month == date.month &&
          r.createdAt.day == date.day
        ).toList();
        
        dailyStats[date] = DailyPrayerStats.fromRecords(date, dayRecords);
      }
    }

    // Calculate streak based on type
    final sortedDates = dailyStats.keys.toList()..sort();
    
    for (int i = 0; i < sortedDates.length; i++) {
      final dayStats = dailyStats[sortedDates[i]]!;
      bool meetsCriteria = false;

      switch (type) {
        case StreakType.completion:
          meetsCriteria = dayStats.completionRate == 100;
          break;
        case StreakType.consistency:
          meetsCriteria = dayStats.completionRate >= 80;
          break;
        case StreakType.jamaat:
          final jamaatCount = dayStats.prayers.values
              .where((r) => r?.isJamaat == true)
              .length;
          meetsCriteria = jamaatCount >= 3; // At least 3 prayers in jamaat
          break;
      }

      if (meetsCriteria) {
        if (tempStreak == 0) {
          streakStart = sortedDates[i];
        }
        tempStreak++;
        lastPrayerDate = sortedDates[i];
        
        if (i == sortedDates.length - 1) {
          // This is the last day, so it's the current streak
          currentStreak = tempStreak;
        }
      } else {
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 0;
      }
    }

    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return PrayerStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      streakStartDate: streakStart,
      lastPrayerDate: lastPrayerDate,
      type: type,
    );
  }
}

enum StreakType {
  completion,
  consistency,
  jamaat,
}

class WeeklyProgress {
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<int, DailyPrayerStats> dailyStats; // weekday -> stats
  final double weeklyCompletionRate;
  final int totalCompletedPrayers;
  final int totalPossiblePrayers;

  const WeeklyProgress({
    required this.weekStart,
    required this.weekEnd,
    required this.dailyStats,
    required this.weeklyCompletionRate,
    required this.totalCompletedPrayers,
    required this.totalPossiblePrayers,
  });

  factory WeeklyProgress.fromRecords(
    DateTime weekStart,
    List<PrayerRecord> weekRecords,
  ) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dailyStats = <int, DailyPrayerStats>{};
    
    int totalCompleted = 0;
    int totalPossible = 0;

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayRecords = weekRecords.where((r) => 
        r.createdAt.year == date.year &&
        r.createdAt.month == date.month &&
        r.createdAt.day == date.day
      ).toList();

      final dayStats = DailyPrayerStats.fromRecords(date, dayRecords);
      dailyStats[date.weekday] = dayStats;
      
      totalCompleted += dayStats.completedCount;
      totalPossible += dayStats.totalCount;
    }

    final weeklyRate = totalPossible > 0 ? (totalCompleted / totalPossible) * 100 : 0.0;

    return WeeklyProgress(
      weekStart: weekStart,
      weekEnd: weekEnd,
      dailyStats: dailyStats,
      weeklyCompletionRate: weeklyRate,
      totalCompletedPrayers: totalCompleted,
      totalPossiblePrayers: totalPossible,
    );
  }
}