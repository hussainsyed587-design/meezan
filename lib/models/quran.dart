class QuranSurah {
  final int number;
  final String name;
  final String englishName;
  final String englishTranslation;
  final String revelationType;
  final int numberOfAyahs;
  
  QuranSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });
  
  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishTranslation: json['englishNameTranslation'] ?? '',
      revelationType: json['revelationType'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishTranslation,
      'revelationType': revelationType,
      'numberOfAyahs': numberOfAyahs,
    };
  }
}

class QuranAyah {
  final int number;
  final String text;
  final String translation;
  final int surah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  
  QuranAyah({
    required this.number,
    required this.text,
    required this.translation,
    required this.surah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
  });
  
  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      translation: json['translation'] ?? '',
      surah: json['surah'] ?? 0,
      juz: json['juz'] ?? 0,
      manzil: json['manzil'] ?? 0,
      page: json['page'] ?? 0,
      ruku: json['ruku'] ?? 0,
      hizbQuarter: json['hizbQuarter'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'translation': translation,
      'surah': surah,
      'juz': juz,
      'manzil': manzil,
      'page': page,
      'ruku': ruku,
      'hizbQuarter': hizbQuarter,
    };
  }
}

class QuranBookmark {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String note;
  final DateTime createdAt;
  
  QuranBookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.note,
    required this.createdAt,
  });
  
  factory QuranBookmark.fromJson(Map<String, dynamic> json) {
    return QuranBookmark(
      id: json['id'] ?? '',
      surahNumber: json['surahNumber'] ?? 0,
      ayahNumber: json['ayahNumber'] ?? 0,
      surahName: json['surahName'] ?? '',
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}