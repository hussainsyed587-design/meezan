import 'package:flutter/foundation.dart';

class HijriDate {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String dayOfWeek;
  final DateTime gregorianDate;
  final List<IslamicEvent> events;
  final bool isHoliday;
  final bool isFasting;

  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.dayOfWeek,
    required this.gregorianDate,
    this.events = const [],
    this.isHoliday = false,
    this.isFasting = false,
  });

  String get formattedDate => '$day $monthName $year AH';
  
  String get shortFormat => '$day/$month/$year';
  
  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      day: json['day'] ?? 1,
      month: json['month'] ?? 1,
      year: json['year'] ?? 1444,
      monthName: json['monthName'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      gregorianDate: DateTime.parse(json['gregorianDate'] ?? DateTime.now().toIso8601String()),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => IslamicEvent.fromJson(e))
          .toList() ?? [],
      isHoliday: json['isHoliday'] ?? false,
      isFasting: json['isFasting'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'monthName': monthName,
      'dayOfWeek': dayOfWeek,
      'gregorianDate': gregorianDate.toIso8601String(),
      'events': events.map((e) => e.toJson()).toList(),
      'isHoliday': isHoliday,
      'isFasting': isFasting,
    };
  }
}

class IslamicEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRecurring;
  final int priority; // 1-5, 5 being highest
  final String? imageUrl;
  final List<String> tags;

  const IslamicEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    this.endDate,
    this.isRecurring = false,
    this.priority = 3,
    this.imageUrl,
    this.tags = const [],
  });

  bool get isMultiDay => endDate != null && endDate!.isAfter(startDate);
  
  Duration get duration => endDate?.difference(startDate) ?? const Duration(days: 1);

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.other,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isRecurring: json['isRecurring'] ?? false,
      priority: json['priority'] ?? 3,
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isRecurring': isRecurring,
      'priority': priority,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }
}

enum EventType {
  religious,
  fasting,
  pilgrimage,
  celebration,
  historical,
  community,
  personal,
  other,
}

class FastingDay {
  final String id;
  final String name;
  final String description;
  final FastingType type;
  final bool isObligatory;
  final DateTime date;
  final String? reward;
  final List<String> guidelines;

  const FastingDay({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isObligatory,
    required this.date,
    this.reward,
    this.guidelines = const [],
  });

  factory FastingDay.fromJson(Map<String, dynamic> json) {
    return FastingDay(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: FastingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FastingType.voluntary,
      ),
      isObligatory: json['isObligatory'] ?? false,
      date: DateTime.parse(json['date']),
      reward: json['reward'],
      guidelines: List<String>.from(json['guidelines'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'isObligatory': isObligatory,
      'date': date.toIso8601String(),
      'reward': reward,
      'guidelines': guidelines,
    };
  }
}

enum FastingType {
  ramadan,
  voluntary,
  ashura,
  arafah,
  mondayThursday,
  whitedays,
  other,
}

class MonthInfo {
  final int monthNumber;
  final String arabicName;
  final String englishName;
  final String description;
  final int days;
  final List<String> significance;
  final String? imageUrl;

  const MonthInfo({
    required this.monthNumber,
    required this.arabicName,
    required this.englishName,
    required this.description,
    required this.days,
    this.significance = const [],
    this.imageUrl,
  });

  factory MonthInfo.fromJson(Map<String, dynamic> json) {
    return MonthInfo(
      monthNumber: json['monthNumber'] ?? 1,
      arabicName: json['arabicName'] ?? '',
      englishName: json['englishName'] ?? '',
      description: json['description'] ?? '',
      days: json['days'] ?? 30,
      significance: List<String>.from(json['significance'] ?? []),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthNumber': monthNumber,
      'arabicName': arabicName,
      'englishName': englishName,
      'description': description,
      'days': days,
      'significance': significance,
      'imageUrl': imageUrl,
    };
  }
}