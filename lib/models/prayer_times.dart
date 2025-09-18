class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final String firstthird;
  final String lastthird;
  final DateTime date;
  final String hijriDate;
  
  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.firstthird,
    required this.lastthird,
    required this.date,
    required this.hijriDate,
  });
  
  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final gregorian = date['gregorian'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    
    return PrayerTimes(
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      sunset: _cleanTime(timings['Sunset']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      imsak: _cleanTime(timings['Imsak']),
      midnight: _cleanTime(timings['Midnight']),
      firstthird: _cleanTime(timings['Firstthird']),
      lastthird: _cleanTime(timings['Lastthird']),
      date: _parseDate(gregorian['date']),
      hijriDate: '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'sunset': sunset,
      'maghrib': maghrib,
      'isha': isha,
      'imsak': imsak,
      'midnight': midnight,
      'firstthird': firstthird,
      'lastthird': lastthird,
      'date': date.toIso8601String(),
      'hijriDate': hijriDate,
    };
  }
  
  static String _cleanTime(String time) {
    // Remove timezone info and keep only HH:MM format
    return time.split(' ')[0];
  }
  
  static DateTime _parseDate(String dateStr) {
    try {
      // Handle DD-MM-YYYY format from Aladhan API
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
      // Fallback to standard parsing
      return DateTime.parse(dateStr);
    } catch (e) {
      // If parsing fails, return current date
      return DateTime.now();
    }
  }
  
  List<Prayer> get prayerList => [
    Prayer(name: 'Fajr', time: fajr, isCompleted: false),
    Prayer(name: 'Dhuhr', time: dhuhr, isCompleted: false),
    Prayer(name: 'Asr', time: asr, isCompleted: false),
    Prayer(name: 'Maghrib', time: maghrib, isCompleted: false),
    Prayer(name: 'Isha', time: isha, isCompleted: false),
  ];
  
  Prayer? getNextPrayer() {
    final now = DateTime.now();
    final prayers = prayerList;
    
    for (final prayer in prayers) {
      final prayerTime = _parseTime(prayer.time);
      if (prayerTime.isAfter(now)) {
        return prayer;
      }
    }
    
    // If no prayer left today, return Fajr of next day
    return Prayer(
      name: 'Fajr',
      time: fajr,
      isCompleted: false,
      isNextDay: true,
    );
  }
  
  Duration getTimeUntilNextPrayer() {
    final nextPrayer = getNextPrayer();
    if (nextPrayer == null) return Duration.zero;
    
    final now = DateTime.now();
    var prayerTime = _parseTime(nextPrayer.time);
    
    if (nextPrayer.isNextDay) {
      prayerTime = prayerTime.add(const Duration(days: 1));
    }
    
    return prayerTime.difference(now);
  }
  
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

class Prayer {
  final String name;
  final String time;
  final bool isCompleted;
  final bool isNextDay;
  
  Prayer({
    required this.name,
    required this.time,
    required this.isCompleted,
    this.isNextDay = false,
  });
  
  Prayer copyWith({
    String? name,
    String? time,
    bool? isCompleted,
    bool? isNextDay,
  }) {
    return Prayer(
      name: name ?? this.name,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      isNextDay: isNextDay ?? this.isNextDay,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'isCompleted': isCompleted,
      'isNextDay': isNextDay,
    };
  }
  
  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      name: json['name'],
      time: json['time'],
      isCompleted: json['isCompleted'] ?? false,
      isNextDay: json['isNextDay'] ?? false,
    );
  }
}