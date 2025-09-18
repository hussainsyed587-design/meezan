class Dua {
  final String id;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String englishText;
  final String category;
  final String? audioUrl;
  final String? reference;
  final bool isFavorite;
  final int repetitionCount;
  
  Dua({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.englishText,
    required this.category,
    this.audioUrl,
    this.reference,
    this.isFavorite = false,
    this.repetitionCount = 1,
  });
  
  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] ?? '',
      arabicText: json['arabicText'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translation: json['translation'] ?? '',
      englishText: json['englishText'] ?? '',
      category: json['category'] ?? '',
      audioUrl: json['audioUrl'],
      reference: json['reference'],
      isFavorite: json['isFavorite'] ?? false,
      repetitionCount: json['repetitionCount'] ?? 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'englishText': englishText,
      'category': category,
      'audioUrl': audioUrl,
      'reference': reference,
      'isFavorite': isFavorite,
      'repetitionCount': repetitionCount,
    };
  }
  
  Dua copyWith({
    String? id,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? englishText,
    String? category,
    String? audioUrl,
    String? reference,
    bool? isFavorite,
    int? repetitionCount,
  }) {
    return Dua(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      englishText: englishText ?? this.englishText,
      category: category ?? this.category,
      audioUrl: audioUrl ?? this.audioUrl,
      reference: reference ?? this.reference,
      isFavorite: isFavorite ?? this.isFavorite,
      repetitionCount: repetitionCount ?? this.repetitionCount,
    );
  }
}

class DuaCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final List<Dua> duas;
  
  DuaCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.duas = const [],
  });
  
  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    final duasList = (json['duas'] as List<dynamic>?)
        ?.map((duaJson) => Dua.fromJson(duaJson as Map<String, dynamic>))
        .toList() ?? [];
    
    return DuaCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? '',
      duas: duasList,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'duas': duas.map((dua) => dua.toJson()).toList(),
    };
  }
}

class Hadith {
  final String id;
  final String arabicText;
  final String englishText;
  final String narrator;
  final String book;
  final String chapter;
  final String hadithNumber;
  final String grade;
  final bool isFavorite;
  
  Hadith({
    required this.id,
    required this.arabicText,
    required this.englishText,
    required this.narrator,
    required this.book,
    required this.chapter,
    required this.hadithNumber,
    this.grade = '',
    this.isFavorite = false,
  });
  
  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] ?? '',
      arabicText: json['arabicText'] ?? '',
      englishText: json['englishText'] ?? '',
      narrator: json['narrator'] ?? '',
      book: json['book'] ?? '',
      chapter: json['chapter'] ?? '',
      hadithNumber: json['hadithNumber'] ?? '',
      grade: json['grade'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicText': arabicText,
      'englishText': englishText,
      'narrator': narrator,
      'book': book,
      'chapter': chapter,
      'hadithNumber': hadithNumber,
      'grade': grade,
      'isFavorite': isFavorite,
    };
  }
  
  Hadith copyWith({
    String? id,
    String? arabicText,
    String? englishText,
    String? narrator,
    String? book,
    String? chapter,
    String? hadithNumber,
    String? grade,
    bool? isFavorite,
  }) {
    return Hadith(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      englishText: englishText ?? this.englishText,
      narrator: narrator ?? this.narrator,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      grade: grade ?? this.grade,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  
  String get reference => '$book - $hadithNumber';
}